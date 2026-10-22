StablesConfig = {
    -- Bounded readiness wait per dependency. Owned schema initializes at startup.
    startupTimeoutMs = 30000,
    -- Capacity used only by the internal reservation repository; no purchase RPC.
    ownedHorseLimit = 3,
    -- Temporary console-only SQL acceptance fixture; keep false outside testing.
    repositoryProof = false,
    -- Disposable Phase 0 horse test. Console-only; keep false in production.
    entityProof = {
        enabled = false,
        -- Explicit experiment selection; never auto-fallback after a timeout.
        spawnMode = 'client_lease', -- 'client_lease' or 'server_rpc'
    },
}
