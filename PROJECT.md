# An AI Learns Monza

*Reinforcement learning vs. optimal control for minimum-time racing*

## Summary

A reinforcement-learning (RL) agent learns to drive an F1-style car around Monza as fast as possible, choosing throttle, brake, steering and racing line itself. Its laps are then compared with a minimum-time optimal-control solution computed on the **same vehicle model**, and with real F1 telemetry. The central question: **where and why does RL lose time against optimal control?**

## Goals (in priority order)

1. **Learn RL in practice.** Understand, and be able to defend, every line of code.
2. **Answer a research question.** Quantify and explain the gap between RL and minimum-time optimal control.
3. **Portfolio.** A clean repository, a short video and a project page, in support of PhD applications in robotics / physical AI.

When goals conflict, the higher one wins: a smaller project that is fully understood beats a polished one that is not.

## Constraints

- **Hardware:** laptop CPU only (Intel i5-10210U, 4 cores / 8 threads, 16 GB RAM). State-based observations, no pixels, small networks.
- **Budget:** €0. Free and open-source tools and data only.
- **Time:** about 2 hours a day on average, no fixed deadline.
- **Always something finished:** every stage ends with a working, presentable result.
- **Working method:** the author writes the code; an AI assistant is used for explanations, code review and debugging.

## Key decisions

| Topic | Decision |
|---|---|
| Headline result | Stage 1: RL laps Monza. Stage 2: RL vs. optimal control vs. real F1 data. |
| Vehicle | F1-style car with publicly estimated parameters from one pre-2026 season. Mass is a parameter (fuel load); fuel burn is ignored for single-lap runs (~0.2 % of mass per lap). |
| Fairness rule | The RL environment and the optimal-control solver use the same vehicle-model code and the same parameter file. |
| Observations | Track-relative state (speed, heading error, lateral offset) plus curvature preview ahead. Range-sensor "rays" kept as a later ablation. |
| Algorithms | Own minimal PPO on toy problems first; Stable-Baselines3 PPO for the car. |
| Track data | TUM racetrack database (Monza centreline and widths; widths are approximate). |
| Real data | FastF1 library (timing and telemetry). Availability to be verified. |
| Dev environment | Docker (Docker Desktop + WSL2) with a VS Code Dev Container; the `Dockerfile` lives in the repo. |
| Version control | Feature branches + pull requests, Conventional Commits, a git tag per finished stage. |
| Quality | `pytest` tests (physics and track geometry first), GitHub Actions CI on every push. |
| Repository | Public from day 1, MIT license. |

## Stages

### Stage 0: Setup
- Docker Desktop + WSL2, VS Code Dev Container, `Dockerfile` in the repo.
- Git recap; public repository; this file as the first commit.
- CI skeleton running one trivial test.

**Done when:** the container builds from a clean clone and CI passes on push.

### Stage 0.5: RL foundations
- Own minimal PPO in PyTorch: CartPole (discrete actions), then Pendulum (continuous actions).

**Done when:** own PPO solves CartPole-v1 (mean return ≥ 475 over 100 episodes) and learns Pendulum to a mean return around −200 or better.

### Stage 1: Finish a lap
- Track loading and geometry: centreline, normals, edges, curvature, arc length.
- Kinematic bicycle model (with a speed cap, since it has no grip limit).
- Gymnasium environment: observations, actions (steering, throttle/brake), reward (progress, off-track penalty).
- SB3 PPO training with parallel environments.
- Evaluation script and an animation of the car improving during training.

**Done when:** the agent completes ≥ 9 of 10 evaluation laps without leaving the track; lap time reported (not a target, since the model has no grip limit); GIF and README with one-command reproduction; tagged `v0.1`.

### Stage 2: Go fast
- Optimal-control refresher: direct methods (multiple shooting, collocation) with CasADi on toy problems.
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

## Deliverables

- GitHub repository with README, results and one-command reproduction.
- A 2–3 minute video ("An AI learns Monza", RL vs. optimal racing line overlaid).
- A project page on a personal website.

## Open questions

- Which pre-2026 season and which reference qualifying lap.
- Sources for F1 parameter estimates (mass, power, aero coefficients, tyre grip).
- TUM's trajectory optimiser vs. an own CasADi formulation.
- RL algorithm for stage 2 (PPO vs. SAC).
- Stage 2 target for the RL vs. optimal-control gap (to be set after first results).

## References

- Wurman et al., "Outracing champion Gran Turismo drivers with deep reinforcement learning", *Nature*, 2022 (GT Sophy).
- Song et al., "Reaching the limit in autonomous racing: Optimal control versus reinforcement learning", *Science Robotics*, 2023 (drone racing).
- Schulman et al., "Proximal Policy Optimization Algorithms", 2017.
- Pacejka, *Tyre and Vehicle Dynamics*.
- TUM FTM: [racetrack-database](https://github.com/TUMFTM/racetrack-database), [global_racetrajectory_optimization](https://github.com/TUMFTM/global_racetrajectory_optimization).
