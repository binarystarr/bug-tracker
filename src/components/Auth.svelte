<script lang="ts">
  import { supabase } from '../lib/supabase'
  import PasswordResetRequest from './PasswordResetRequest.svelte'

  let isLogin = true
  let showPasswordReset = false
  let email = ''
  let password = ''
  let loading = false
  let message = ''

  async function handleAuth() {
    if (!email || !password) {
      message = 'Please fill in all fields'
      return
    }

    loading = true
    message = ''

    try {
      if (isLogin) {
        // Sign in
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        
        if (error) throw error
        message = 'Welcome back!'
      } else {
        // Sign up
        const { error } = await supabase.auth.signUp({
          email,
          password,
        })
        
        if (error) throw error
        message = 'Check your email for verification link!'
      }
    } catch (error) {
      message = error instanceof Error ? error.message : 'An error occurred'
    } finally {
      loading = false
    }
  }

  function toggleMode() {
    isLogin = !isLogin
    message = ''
  }

  function showPasswordResetForm() {
    showPasswordReset = true
    message = ''
  }

  function hidePasswordResetForm() {
    showPasswordReset = false
    message = ''
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      handleAuth()
    }
  }
</script>

{#if showPasswordReset}
  <PasswordResetRequest onBack={hidePasswordResetForm} />
{:else}
<div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <div>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        {isLogin ? 'Sign in to Bug Tracker' : 'Create your account'}
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Track and manage your bugs efficiently
      </p>
    </div>
    
    <form class="mt-8 space-y-6" on:submit|preventDefault={handleAuth}>
      <div class="space-y-4">
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
        
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700">
            Password
          </label>
          <input
            id="password"
            name="password"
            type="password"
            autocomplete={isLogin ? 'current-password' : 'new-password'}
            required
            bind:value={password}
            on:keydown={handleKeydown}
            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="Enter your password"
          />
        </div>
      </div>

      {#if message}
        <div class="rounded-md p-4 {message.includes('error') || message.includes('Invalid') ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}">
          <p class="text-sm">{message}</p>
        </div>
      {/if}

      <div>
        <button
          type="submit"
          disabled={loading}
          class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Loading...' : isLogin ? 'Sign in' : 'Sign up'}
        </button>
      </div>

      <div class="text-center space-y-2">
        <button
          type="button"
          on:click={toggleMode}
          class="text-sm text-blue-600 hover:text-blue-500 block w-full"
        >
          {isLogin ? "Don't have an account? Sign up" : 'Already have an account? Sign in'}
        </button>
        
        {#if isLogin}
          <button
            type="button"
            on:click={showPasswordResetForm}
            class="text-sm text-gray-600 hover:text-gray-500"
          >
            Forgot your password?
          </button>
        {/if}
      </div>
    </form>
  </div>
</div>
{/if} 