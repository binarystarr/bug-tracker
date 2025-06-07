<script lang="ts">
  import { format } from 'date-fns'
  import type { Bug } from '../lib/supabase'

  export let bug: Bug
  export let onStatusChange: (id: string, status: Bug['status']) => void
  export let onEdit: (bug: Bug) => void
  export let onDelete: (id: string) => void

  const statusColors = {
    open: 'bg-red-100 text-red-800',
    in_progress: 'bg-yellow-100 text-yellow-800',
    resolved: 'bg-green-100 text-green-800',
    closed: 'bg-gray-100 text-gray-800'
  }

  const priorityColors = {
    low: 'bg-blue-100 text-blue-800',
    medium: 'bg-orange-100 text-orange-800',
    high: 'bg-red-100 text-red-800',
    critical: 'bg-purple-100 text-purple-800'
  }
</script>

<div class="bg-white rounded-lg shadow-md p-6 border border-gray-200">
  <div class="flex justify-between items-start mb-4">
    <h3 class="text-lg font-semibold text-gray-900">{bug.title}</h3>
    <div class="flex gap-2">
      <span class="px-2 py-1 text-xs font-medium rounded-full {statusColors[bug.status]}">
        {bug.status.replace('_', ' ')}
      </span>
      <span class="px-2 py-1 text-xs font-medium rounded-full {priorityColors[bug.priority]}">
        {bug.priority}
      </span>
    </div>
  </div>

  {#if bug.description}
    <p class="text-gray-600 mb-4">{bug.description}</p>
  {/if}

  <div class="flex justify-between items-center text-sm text-gray-500 mb-4">
    <div>
      <span>Created: {format(new Date(bug.created_at), 'MMM d, yyyy')}</span>
      {#if bug.reporter}
        <span class="ml-2">by {bug.reporter}</span>
      {/if}
    </div>
    {#if bug.assigned_to}
      <span>Assigned to: {bug.assigned_to}</span>
    {/if}
  </div>

  <div class="flex gap-2">
    <select 
      class="border border-gray-300 rounded px-3 py-1 text-sm"
      value={bug.status}
      on:change={(e) => onStatusChange(bug.id, e.target.value as Bug['status'])}
    >
      <option value="open">Open</option>
      <option value="in_progress">In Progress</option>
      <option value="resolved">Resolved</option>
      <option value="closed">Closed</option>
    </select>

    <button 
      class="px-3 py-1 text-sm bg-blue-500 text-white rounded hover:bg-blue-600"
      on:click={() => onEdit(bug)}
    >
      Edit
    </button>

    <button 
      class="px-3 py-1 text-sm bg-red-500 text-white rounded hover:bg-red-600"
      on:click={() => onDelete(bug.id)}
    >
      Delete
    </button>
  </div>
</div>

<style>
  /* Add Tailwind CSS classes */
</style> 