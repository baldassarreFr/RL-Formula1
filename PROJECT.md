# An AI Learns Monza

*Reinforcement learning vs. optimal control for minimum-time racing*

## Summary

A reinforcement-learning (RL) agent learns to drive an F1-style car around Monza as fast as possible, choosing throttle, brake, steering and racing line itself. Its laps are then compared with a minimum-time optimal-control solution computed on the **same vehicle model**, and with real F1 telemetry. The central question: **where and why does RL lose time against optimal control?**


## Key decisions

| Topic | Decision |
|---|---|
| Headline result | Stage 1: RL laps Monza. Stage 2: RL vs. optimal control vs. real F1 data. |
| Vehicle | F1-style car with publicly estimated parameters from one pre-2026 season. Mass is a parameter (fuel load); fuel burn is ignored for single-lap runs (~0.2 % of mass per lap). |
| Fairness rule | The RL environment and the optimal-control solver use the same vehicle-model code and the same parameter file. |
| Observations | Track-relative state (speed, heading error, lateral offset) plus curvature preview ahead. Range-sensor "rays" kept as a later ablation. |
| Track data | TUM racetrack database (Monza centreline and widths; widths are approximate). |
| Real data | FastF1 library (timing and telemetry). |
| Dev environment | Docker (Docker Desktop + WSL2) with a VS Code Dev Container; the `Dockerfile` lives in the repo. |
| Quality | `pytest` tests (physics and track geometry first), GitHub Actions CI on every push. |


## Stages

### Stage 0: Setup
- Docker Desktop + WSL2, VS Code Dev Container, `Dockerfile` in the repo.
- Git recap; public repository.
- CI skeleton running one trivial test.

### Stage 1: Finish a lap
- Track loading and geometry: centreline, normals, edges, curvature, arc length.
- Kinematic bicycle model (with a speed cap, since it has no grip limit).
- Gymnasium environment: observations, actions (steering, throttle/brake), reward (progress, off-track penalty).
- SB3 PPO training with parallel environments.
- Evaluation script and an animation of the car improving during training.

**Goal:** the agent completes at least 9 laps out of 10 without leaving the track; lap time reported (not a target, since the model has no grip limit); tagged `v0.1`.

### Stage 2: Go fast
- F1-style vehicle model (see the vehicle-model ladder below).
- Minimum-time optimal-control problem on Monza, using the same model and parameters as the RL environment.
- Model validation against a real qualifying lap (FastF1): lap time within about 5–10 %, similar speed-trace shape.
- RL on the dynamic model; comparison of lap time, racing line, speed profile and braking points.

**Done when:** the vehicle model is validated, and the RL vs. optimal-control gap is quantified and explained; tagged `v0.2`.

### Stage 3: Optional extensions
- Range-sensor observation ablation.
- Generalisation to unseen circuits.
- Variable grip (rain).
- Sim-to-real on an Elegoo Arduino car on a tape track.
- Higher-fidelity tyre model (level 4 below).

## Vehicle-model ladder

| Level | Model | Used in |
|---|---|---|
| 1 | Kinematic bicycle, speed cap | Stage 1 |
| 2 | Point mass + friction ellipse, downforce, drag, power limit | Stage 2 (first version, OCP validation) |
| 3 | Dynamic single-track (bicycle) model: Pacejka tyres, combined slip, axle load transfer, aero balance | Stage 2 (main) |
| 4 | Double-track (four-wheel) model, tyre load sensitivity, tyre temperature | Stage 3, optional |

Each level is validated before moving to the next. Fidelity is limited by what can be parameterised from public data; beyond that point extra detail is false precision.
