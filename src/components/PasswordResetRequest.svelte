<script lang="ts">
  import { supabase } from '../lib/supabase'

  export let onBack: () => void

  let email = ''
  let loading = false
  let message = ''

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
      
      message = 'Password reset email sent! Check your inbox and click the link to reset your password.'
    } catch (error) {
      message = error instanceof Error ? error.message : 'An error occurred'
    } finally {
      loading = false
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      handlePasswordReset()
    }
  }
</script>

<div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <div>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Reset Your Password
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Enter your email to receive a reset link
      </p>
    </div>
    
    <form class="mt-8 space-y-6" on:submit|preventDefault={handlePasswordReset}>
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

      {#if message}
        <div class="rounded-md p-4 {message.includes('error') ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}">
          <p class="text-sm">{message}</p>
        </div>
      {/if}

      <div>
        <button
          type="submit"
          disabled={loading}
          class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Sending...' : 'Send Reset Email'}
        </button>
      </div>

      <div class="text-center">
        <button
          type="button"
          on:click={onBack}
          class="text-sm text-blue-600 hover:text-blue-500"
        >
          Back to Sign In
        </button>
      </div>
    </form>
  </div>
</div> 