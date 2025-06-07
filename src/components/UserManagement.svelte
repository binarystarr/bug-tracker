<script lang="ts">
  import { supabase } from '../lib/supabase'
  import { onMount } from 'svelte'

  export let onClose: () => void

  let users: any[] = []
  let loading = false
  let newUserEmail = ''
  let newUserPassword = ''
  let message = ''
  let showAddForm = false

  onMount(async () => {
    await loadUsers()
  })

  async function loadUsers() {
    loading = true
    try {
      // Try to use admin API to list users
      const { data: authUsers, error: authError } = await supabase.auth.admin.listUsers()
      
      if (authError) {
        console.log('Admin API not available, trying profiles table...')
        // Fallback to profiles table
        const { data, error } = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', { ascending: false })

        if (error && error.code !== 'PGRST116') { // PGRST116 = table doesn't exist
          throw error
        }

        users = data || []
      } else {
        // Successfully got users from admin API - filter for active users only
        const activeUsers = (authUsers.users || []).filter(user => 
          user.last_sign_in_at !== null && user.last_sign_in_at !== undefined
        )
        
        // Sort by last sign in date (most recent first)
        users = activeUsers.sort((a, b) => 
          new Date(b.last_sign_in_at).getTime() - new Date(a.last_sign_in_at).getTime()
        )
        
        console.log(`Found ${users.length} active users out of ${authUsers.users?.length || 0} total users`)
      }
    } catch (error) {
      console.log('Could not load users:', error)
      users = []
    } finally {
      loading = false
    }
  }

  async function addUser() {
    if (!newUserEmail || !newUserPassword) {
      message = 'Please fill in all fields'
      return
    }

    if (newUserPassword.length < 6) {
      message = 'Password must be at least 6 characters'
      return
    }

    loading = true
    message = ''

    try {
      // Use Supabase admin API to create user with auto-confirmation
      const { data, error } = await supabase.auth.admin.createUser({
        email: newUserEmail,
        password: newUserPassword,
        email_confirm: true // Auto-confirm to skip verification email
      })

      if (error) throw error

      message = `User ${newUserEmail} created successfully!`
      newUserEmail = ''
      newUserPassword = ''
      showAddForm = false
      await loadUsers()
    } catch (error) {
      // If admin API isn't available, use regular signup
      try {
        const { error: signupError } = await supabase.auth.signUp({
          email: newUserEmail,
          password: newUserPassword,
        })
        
        if (signupError) throw signupError
        
        message = `User ${newUserEmail} created! They need to verify their email.`
        newUserEmail = ''
        newUserPassword = ''
        showAddForm = false
        await loadUsers()
      } catch (fallbackError) {
        message = fallbackError instanceof Error ? fallbackError.message : 'Failed to create user'
      }
    } finally {
      loading = false
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      addUser()
    }
  }
</script>

<div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
  <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-hidden">
    <!-- Header -->
    <div class="bg-gray-50 px-6 py-4 border-b">
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold text-gray-900">User Management</h2>
        <button
          on:click={onClose}
          class="text-gray-400 hover:text-gray-600 text-2xl"
        >
          ×
        </button>
      </div>
    </div>

    <!-- Content -->
    <div class="p-6 overflow-y-auto max-h-[calc(90vh-8rem)]">
      <!-- Add User Section -->
      <div class="mb-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900">Add New User</h3>
          <button
            on:click={() => showAddForm = !showAddForm}
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 text-sm"
          >
            {showAddForm ? 'Cancel' : 'Add User'}
          </button>
        </div>

        {#if showAddForm}
          <div class="bg-gray-50 p-4 rounded-lg space-y-4">
            <div>
              <label for="newEmail" class="block text-sm font-medium text-gray-700 mb-1">
                Email Address
              </label>
              <input
                id="newEmail"
                type="email"
                bind:value={newUserEmail}
                on:keydown={handleKeydown}
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="user@example.com"
              />
            </div>

            <div>
              <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-1">
                Password
              </label>
              <input
                id="newPassword"
                type="password"
                bind:value={newUserPassword}
                on:keydown={handleKeydown}
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Min 6 characters"
              />
            </div>

            <button
              on:click={addUser}
              disabled={loading}
              class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 text-sm"
            >
              {loading ? 'Creating...' : 'Create User'}
            </button>
          </div>
        {/if}

        {#if message}
          <div class="mt-4 p-3 rounded-md {message.includes('successfully') || message.includes('created') ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}">
            <p class="text-sm">{message}</p>
          </div>
        {/if}
      </div>

      <!-- Users List -->
      <div>
        <h3 class="text-lg font-medium text-gray-900 mb-4">Active Users</h3>
        
        {#if loading && users.length === 0}
          <div class="text-center py-8">
            <div class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
            <p class="mt-2 text-gray-600 text-sm">Loading users...</p>
          </div>
        {:else if users.length === 0}
          <div class="text-center py-8 text-gray-500">
            <p>No active users found.</p>
            <p class="text-sm mt-1">Showing only users who have signed in at least once.</p>
            <p class="text-sm mt-1">To view all users (including those who haven't signed in), check your Supabase dashboard → Authentication → Users</p>
            <div class="mt-4 p-3 bg-blue-50 text-blue-700 rounded-md text-sm">
              <p><strong>Note:</strong> richard.starr@elixirr.com exists in Supabase but will only appear here after signing in once.</p>
            </div>
          </div>
        {:else}
          <div class="bg-white border rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Sign In
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                {#each users as user}
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {user.email || user.id}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {user.last_sign_in_at 
                        ? new Date(user.last_sign_in_at).toLocaleDateString() + ' ' + new Date(user.last_sign_in_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
                        : user.created_at 
                          ? new Date(user.created_at).toLocaleDateString()
                          : 'Unknown'
                      }
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                        Active
                      </span>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {/if}
      </div>
    </div>

    <!-- Footer -->
    <div class="bg-gray-50 px-6 py-3 border-t">
      <div class="flex justify-end">
        <button
          on:click={onClose}
          class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 text-sm"
        >
          Close
        </button>
      </div>
    </div>
  </div>
</div> 