# Concern: simulation-engine

> Physics simulation, discrete event simulation, time-stepping, state snapshots, deterministic replay, Monte Carlo methods.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: simulation, physics engine, discrete event simulation, time step, Monte Carlo, state snapshot, deterministic replay, DES, agent-based model

**Secondary**: tick rate, fixed timestep, variable timestep, collision detection, rigid body, particle system, finite element, ray tracing, random seed, stochastic, probability distribution, event queue, simulation clock, rollback

### Code Patterns (R1 — for source analysis)

- Physics: `cannon-js`, `rapier`, `matter-js`, `box2d`, `bullet`, `PhysX`, `ammo.js`, `planck.js`
- DES: `simpy`, `SimPy`, `JaamSim`, `DESMO-J`, `event_queue`, `SimulationClock`
- Monte Carlo: `numpy.random`, `scipy.stats`, `random.seed()`, `@montecarlo`, `MersenneTwister`
- Patterns: `simulate()`, `step()`, `tick()`, `fixedUpdate()`, `snapshot()`, `rollback()`, `replay()`, `deltaTime`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: gpu-compute, data-io
- **Profiles**: —
