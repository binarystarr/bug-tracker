<script lang="ts">
  import { supabase } from '../lib/supabase'

  export let onBack: () => void
  export let accessToken: string = ''

  let email = ''
  let newPassword = ''
  let confirmPassword = ''
  let loading = false
  let message = ''
  let isResetMode = false // true when user has clicked reset link from email

  // Use the access token passed from App component
  $: if (accessToken && !isResetMode) {
    isResetMode = true
    message = 'Please enter your new password'
  }

  // Check if we're in password update mode (user clicked email link)
  import { onMount } from 'svelte'
  
  onMount(() => {
    // Component mounted - ready for password reset
  })

  async function handlePasswordReset() {
    if (!email) {
      message = 'Please enter your email address'
      return
    }

    loading = true
    message = ''

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}`,
      })
      
      if (error) throw error
      
      message = 'Password reset email sent! Check your inbox.'
    } catch (error) {
      message = error instanceof Error ? error.message : 'An error occurred'
    } finally {
      loading = false
    }
  }

  async function handlePasswordUpdate() {
    if (!newPassword || !confirmPassword) {
      message = 'Please fill in all fields'
      return
    }

    if (newPassword !== confirmPassword) {
      message = 'Passwords do not match'
      return
    }

    if (newPassword.length < 6) {
      message = 'Password must be at least 6 characters'
      return
    }

    if (!accessToken) {
      message = 'Recovery session expired. Please request a new password reset.'
      return
    }

    loading = true
    message = ''

    try {
      // Since we kept the recovery session active, updateUser should work directly
      const { error: updateError } = await supabase.auth.updateUser({
        password: newPassword
      })
      
      if (updateError) {
        throw updateError
      }
      
      message = 'Password updated successfully! Redirecting...'
      
      // Go back to login after a short delay
      setTimeout(() => {
        onBack()
      }, 1500)
      
    } catch (error) {
      console.error('Password update error:', error)
      message = error instanceof Error ? error.message : 'An error occurred'
    } finally {
      loading = false
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      if (isResetMode) {
        handlePasswordUpdate()
      } else {
        handlePasswordReset()
      }
    }
  }


</script>

<div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">

  
  <div class="max-w-md w-full space-y-8">
    <div>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        {isResetMode ? 'Set New Password' : 'Reset Your Password'}
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        {isResetMode ? 'Enter your new password below' : 'Enter your email to receive a reset link'}
      </p>
    </div>
    
    <form class="mt-8 space-y-6" on:submit|preventDefault={isResetMode ? handlePasswordUpdate : handlePasswordReset}>
      <div class="space-y-4">
        {#if !isResetMode}
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <input
              id="email"
              name="email"
              type="email"
              autocomplete="email"
              required
              bind:value={email}
              on:keydown={handleKeydown}
              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Enter your email"
            />
          </div>
        {:else}
          <div>
            <label for="newPassword" class="block text-sm font-medium text-gray-700">
              New Password
            </label>
            <input
              id="newPassword"
              name="newPassword"
              type="password"
              autocomplete="new-password"
              required
              bind:value={newPassword}
              on:keydown={handleKeydown}
              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Enter new password"
            />
          </div>
          
          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-gray-700">
              Confirm New Password
            </label>
            <input
              id="confirmPassword"
              name="confirmPassword"
              type="password"
              autocomplete="new-password"
              required
              bind:value={confirmPassword}
              on:keydown={handleKeydown}
              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Confirm new password"
            />
          </div>
        {/if}
      </div>

      {#if message}
        <div class="rounded-md p-4 {message.includes('error') || message.includes('not match') || message.includes('least') ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}">
          <p class="text-sm">{message}</p>
        </div>
      {/if}

      <div>
        <button
          type="submit"
          disabled={loading}
          class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Loading...' : isResetMode ? 'Update Password' : 'Send Reset Email'}
        </button>
      </div>

      {#if !isResetMode}
        <div class="text-center">
          <button
            type="button"
            on:click={onBack}
            class="text-sm text-blue-600 hover:text-blue-500"
          >
            Back to Sign In
          </button>
        </div>
      {/if}
    </form>
  </div>
</div> 