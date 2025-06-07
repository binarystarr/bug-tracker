<script lang="ts">
  import { onMount } from 'svelte'
  import { supabase } from '../lib/supabase'
  import Auth from './Auth.svelte'
  import BugTracker from './BugTracker.svelte'
  import PasswordReset from './PasswordReset.svelte'
  import UserManagement from './UserManagement.svelte'
  import type { User } from '@supabase/supabase-js'

  let user: User | null = null
  let loading = true
  let isPasswordReset = false
  let preservedAccessToken = ''
  let showUserManagement = false

  // Define super admin email (you can make this configurable later)
  const SUPER_ADMIN_EMAIL = 'binarystarr@gmail.com' // Replace with your email
  
  // Check if current user is super admin
  $: isSuperAdmin = user?.email === SUPER_ADMIN_EMAIL

  // Check for password reset token but DON'T clear session
  async function checkAndHandlePasswordReset() {
    if (typeof window !== 'undefined') {
      const hashParams = new URLSearchParams(window.location.hash.substring(1))
      const accessToken = hashParams.get('access_token')
      
      if (accessToken && !isPasswordReset) {
        console.log('Password reset detected')
        isPasswordReset = true
        preservedAccessToken = accessToken
      }
    }
  }

  onMount(async () => {
    // First, check for password reset and clear session if needed
    await checkAndHandlePasswordReset()
    
    // Then check active sessions and set the user
    supabase.auth.getSession().then(({ data: { session } }) => {
      console.log('Initial session check:', {
        hasSession: !!session,
        hasUser: !!session?.user,
        isPasswordReset,
        hash: typeof window !== 'undefined' ? window.location.hash.substring(0, 30) : 'N/A'
      })
      
      // Only set user if we're not in password reset mode
      if (!isPasswordReset) {
        user = session?.user ?? null
      }
      
      loading = false
    })

          // Listen for changes on auth state (signed in, signed out, etc.)
      const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
        // Check for password reset on any auth state change (in case we missed it)
        await checkAndHandlePasswordReset()
        
        loading = false
        
        // Handle different auth events
        if (event === 'SIGNED_IN' && session?.user && !isPasswordReset) {
          // User successfully signed in (not password recovery)
          user = session.user
          if (typeof window !== 'undefined') {
            window.location.hash = '' // Clear any hash params
          }
        } else if (event === 'SIGNED_OUT' && !isPasswordReset) {
          // User signed out (but not during password reset)
          user = null
        } else if (!isPasswordReset) {
          // Only update user if we're not in password reset mode
          user = session?.user ?? null
        }
        
        // If we're in password reset mode, keep user null to show the password reset form
        if (isPasswordReset) {
          user = null
        }
      })

    return () => subscription.unsubscribe()
  })

  async function handleSignOut() {
    try {
      // First check if we have a session
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        // If we have a session, try to sign out normally
        const { error } = await supabase.auth.signOut()
        if (error) {
          console.error('Error signing out:', error)
        }
      }
    } catch (error) {
      console.error('Session check failed:', error)
    }
    
    // Always clear local user state regardless of Supabase result
    user = null
    
    // Clear any hash params
    if (typeof window !== 'undefined') {
      window.location.hash = ''
    }
  }

  function openUserManagement() {
    showUserManagement = true
  }

  function closeUserManagement() {
    showUserManagement = false
  }

  function handlePasswordResetComplete() {
    console.log('Password reset completed, clearing hash and exiting password reset mode')
    isPasswordReset = false
    
    if (typeof window !== 'undefined') {
      window.location.hash = ''
    }
    
    // Check if user is already signed in after password update
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        console.log('User is signed in after password reset')
        user = session.user
      } else {
        console.log('User needs to sign in again')
        user = null
      }
    })
  }
</script>



{#if loading}
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="text-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      <p class="mt-2 text-gray-600">Loading...</p>
    </div>
  </div>
{:else if isPasswordReset}
  <PasswordReset onBack={handlePasswordResetComplete} accessToken={preservedAccessToken} />
{:else if !user}
  <Auth />
{:else}
  <div class="min-h-screen bg-gray-50">
    <!-- Header with user info and logout -->
    <header class="bg-white shadow">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-4">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Bug Tracker</h1>
            <p class="text-sm text-gray-600">Welcome back, {user.email}</p>
          </div>
          <div class="flex items-center space-x-3">
            {#if isSuperAdmin}
              <button
                on:click={openUserManagement}
                class="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Manage Users
              </button>
            {/if}
            <button
              on:click={handleSignOut}
              class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-gray-500 hover:text-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Sign out
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="py-6">
      <BugTracker {user} />
    </main>
  </div>

  <!-- User Management Modal -->
  {#if showUserManagement}
    <UserManagement onClose={closeUserManagement} />
  {/if}
{/if} 