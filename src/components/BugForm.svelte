<script lang="ts">
  import { v4 as uuidv4 } from 'uuid'
  import type { Bug } from '../lib/supabase'
  import type { User } from '@supabase/supabase-js'

  export let bug: Partial<Bug> | null = null
  export let onSubmit: (bug: Partial<Bug>) => void
  export let onCancel: () => void
  export let user: User

  let title = bug?.title || ''
  let description = bug?.description || ''
  let status = bug?.status || 'open'
  let priority = bug?.priority || 'medium'
  let assigned_to = bug?.assigned_to || ''
  let reporter = bug?.reporter || user.email || ''

  let errors: Record<string, string> = {}

  function validateForm() {
    errors = {}
    
    if (!title.trim()) {
      errors.title = 'Title is required'
    }

    return Object.keys(errors).length === 0
  }

  function handleSubmit() {
    if (!validateForm()) return

    const bugData: Partial<Bug> = {
      title: title.trim(),
      description: description.trim() || null,
      status,
      priority,
      assigned_to: assigned_to.trim() || null,
      reporter: reporter.trim() || user.email || null,
      updated_at: new Date().toISOString()
    }

    if (!bug?.id) {
      bugData.id = uuidv4()
      bugData.created_at = new Date().toISOString()
    } else {
      bugData.id = bug.id
    }

    onSubmit(bugData)
  }

  const isEditing = !!bug?.id
</script>

<div class="bg-white rounded-lg shadow-md p-6 border border-gray-200">
  <h2 class="text-xl font-semibold mb-6 text-gray-900">
    {isEditing ? 'Edit Bug' : 'Create New Bug'}
  </h2>

  <form on:submit|preventDefault={handleSubmit} class="space-y-4">
    <div>
      <label for="title" class="block text-sm font-medium text-gray-700 mb-1">
        Title *
      </label>
      <input
        id="title"
        type="text"
        bind:value={title}
        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        class:border-red-500={errors.title}
        placeholder="Enter bug title"
      />
      {#if errors.title}
        <p class="text-red-500 text-sm mt-1">{errors.title}</p>
      {/if}
    </div>

    <div>
      <label for="description" class="block text-sm font-medium text-gray-700 mb-1">
        Description
      </label>
      <textarea
        id="description"
        bind:value={description}
        rows="4"
        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        placeholder="Describe the bug in detail"
      ></textarea>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div>
        <label for="status" class="block text-sm font-medium text-gray-700 mb-1">
          Status
        </label>
        <select
          id="status"
          bind:value={status}
          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="open">Open</option>
          <option value="in_progress">In Progress</option>
          <option value="resolved">Resolved</option>
          <option value="closed">Closed</option>
        </select>
      </div>

      <div>
        <label for="priority" class="block text-sm font-medium text-gray-700 mb-1">
          Priority
        </label>
        <select
          id="priority"
          bind:value={priority}
          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="low">Low</option>
          <option value="medium">Medium</option>
          <option value="high">High</option>
          <option value="critical">Critical</option>
        </select>
      </div>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div>
        <label for="reporter" class="block text-sm font-medium text-gray-700 mb-1">
          Reporter
        </label>
        <input
          id="reporter"
          type="text"
          bind:value={reporter}
          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-gray-50"
          placeholder={user.email || "Who reported this bug?"}
          readonly={!bug?.id}
        />
        {#if !bug?.id}
          <p class="text-xs text-gray-500 mt-1">Automatically set to your email</p>
        {/if}
      </div>

      <div>
        <label for="assigned_to" class="block text-sm font-medium text-gray-700 mb-1">
          Assigned To
        </label>
        <input
          id="assigned_to"
          type="text"
          bind:value={assigned_to}
          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="Who should fix this bug?"
        />
      </div>
    </div>

    <div class="flex gap-3 pt-4">
      <button
        type="submit"
        class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        {isEditing ? 'Update Bug' : 'Create Bug'}
      </button>
      
      <button
        type="button"
        on:click={onCancel}
        class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
      >
        Cancel
      </button>
    </div>
  </form>
</div> 