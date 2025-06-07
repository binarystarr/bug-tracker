<script lang="ts">
  import { onMount } from 'svelte'
  import { supabase, type Bug } from '../lib/supabase'
  import BugCard from './BugCard.svelte'
  import BugForm from './BugForm.svelte'
  import type { User } from '@supabase/supabase-js'

  export let user: User

  let bugs: Bug[] = []
  let showForm = false
  let editingBug: Bug | null = null
  let loading = true
  let error = ''

  // Filters
  let statusFilter = 'all'
  let priorityFilter = 'all'
  let searchTerm = ''

  $: filteredBugs = bugs.filter(bug => {
    const matchesStatus = statusFilter === 'all' || bug.status === statusFilter
    const matchesPriority = priorityFilter === 'all' || bug.priority === priorityFilter
    const matchesSearch = !searchTerm || 
      bug.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (bug.description && bug.description.toLowerCase().includes(searchTerm.toLowerCase()))
    
    return matchesStatus && matchesPriority && matchesSearch
  })

  onMount(() => {
    loadBugs()
  })

  async function loadBugs() {
    try {
      loading = true
      const { data, error: supabaseError } = await supabase
        .from('bugs')
        .select('*')
        .order('created_at', { ascending: false })

      if (supabaseError) throw supabaseError
      bugs = data || []
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to load bugs'
      console.error('Error loading bugs:', err)
    } finally {
      loading = false
    }
  }

  async function createBug(bugData: Partial<Bug>) {
    try {
      const { data, error: supabaseError } = await supabase
        .from('bugs')
        .insert([bugData])
        .select()
        .single()

      if (supabaseError) throw supabaseError
      
      bugs = [data, ...bugs]
      showForm = false
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to create bug'
      console.error('Error creating bug:', err)
    }
  }

  async function updateBug(bugData: Partial<Bug>) {
    try {
      const { data, error: supabaseError } = await supabase
        .from('bugs')
        .update(bugData)
        .eq('id', bugData.id)
        .select()
        .single()

      if (supabaseError) throw supabaseError

      bugs = bugs.map(bug => bug.id === data.id ? data : bug)
      showForm = false
      editingBug = null
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to update bug'
      console.error('Error updating bug:', err)
    }
  }

  async function updateBugStatus(id: string, status: Bug['status']) {
    try {
      const { data, error: supabaseError } = await supabase
        .from('bugs')
        .update({ status, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single()

      if (supabaseError) throw supabaseError

      bugs = bugs.map(bug => bug.id === id ? data : bug)
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to update bug status'
      console.error('Error updating bug status:', err)
    }
  }

  async function deleteBug(id: string) {
    if (!confirm('Are you sure you want to delete this bug?')) return

    try {
      const { error: supabaseError } = await supabase
        .from('bugs')
        .delete()
        .eq('id', id)

      if (supabaseError) throw supabaseError

      bugs = bugs.filter(bug => bug.id !== id)
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to delete bug'
      console.error('Error deleting bug:', err)
    }
  }

  function handleFormSubmit(bugData: Partial<Bug>) {
    if (editingBug) {
      updateBug(bugData)
    } else {
      createBug(bugData)
    }
  }

  function handleEdit(bug: Bug) {
    editingBug = bug
    showForm = true
  }

  function handleCancelForm() {
    showForm = false
    editingBug = null
  }

  function clearError() {
    error = ''
  }
</script>

<div class="max-w-6xl mx-auto p-6">

  {#if error}
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
      <div class="flex justify-between items-center">
        <span>{error}</span>
        <button on:click={clearError} class="text-red-700 hover:text-red-900">×</button>
      </div>
    </div>
  {/if}

  <!-- Controls -->
  <div class="bg-white rounded-lg shadow-md p-6 mb-6">
    <div class="flex flex-wrap gap-4 items-center justify-between">
      <div class="flex flex-wrap gap-4 items-center">
        <input
          type="text"
          placeholder="Search bugs..."
          bind:value={searchTerm}
          class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />

        <select
          bind:value={statusFilter}
          class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="all">All Status</option>
          <option value="open">Open</option>
          <option value="in_progress">In Progress</option>
          <option value="resolved">Resolved</option>
          <option value="closed">Closed</option>
        </select>

        <select
          bind:value={priorityFilter}
          class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="all">All Priority</option>
          <option value="low">Low</option>
          <option value="medium">Medium</option>
          <option value="high">High</option>
          <option value="critical">Critical</option>
        </select>
      </div>

      <button
        on:click={() => { showForm = true; editingBug = null; }}
        class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        + New Bug
      </button>
    </div>

    <div class="mt-4 text-sm text-gray-600">
      Showing {filteredBugs.length} of {bugs.length} bugs
    </div>
  </div>

  <!-- Form -->
  {#if showForm}
    <div class="mb-6">
      <BugForm
        bug={editingBug}
        onSubmit={handleFormSubmit}
        onCancel={handleCancelForm}
        {user}
      />
    </div>
  {/if}

  <!-- Bug List -->
  {#if loading}
    <div class="text-center py-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      <p class="mt-2 text-gray-600">Loading bugs...</p>
    </div>
  {:else if filteredBugs.length === 0}
    <div class="text-center py-8">
      <p class="text-gray-600">
        {bugs.length === 0 ? 'No bugs found. Create your first bug report!' : 'No bugs match your current filters.'}
      </p>
    </div>
  {:else}
    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
      {#each filteredBugs as bug (bug.id)}
        <BugCard
          {bug}
          onStatusChange={updateBugStatus}
          onEdit={handleEdit}
          onDelete={deleteBug}
        />
      {/each}
    </div>
  {/if}
</div> 