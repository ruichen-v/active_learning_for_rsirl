# active_learning_for_rsirl
## Paper code for [Active Learning for Risk-Sensitive Inverse Reinforcement Learning](https://arxiv.org/abs/1909.07843).
## Click the image below (the single-step example in paper) to view the complete convergence process.
[![Demo of single-step RSIRL convergence with active learning.](Docs/img/active.png 'Link to demo video')](https://www.youtube.com/watch?v=QPQkQfWSbDY)

# Table of contents
File | Content
--- | ---
`Data/exp_*/exp_setup.mat` | Decision-making dynamics, expert risk envelope
`Data/exp_*/softmax_*` | Learning results and testing error for active RS-IRL
`Data/exp_*/std_*` | Learning results and testing error for original RS-IRL
`Data/exp_*/testing` | Expert demonstrations for testing
`Demo/` | Code for generating convergence comparison
`Testing/` | Batch running & testing code
`single_step_*.m` | Original / Active RS-IRL
`new_exp.m` | Experiment generator

# Dependencies
* Matlab
* [Multi-Parametric Toolbox 3.0](https://www.mpt3.org/)
* [Mosek Solver](https://www.mosek.com/)
* [Yalmip](https://yalmip.github.io/)

# Run the code
1. Navigate to `SingleStepKnownCost/`
2. Add `Data/`, `Demo/`, `Testing/` to path
3. Run learning / testing code. Change flags to toggle image saving, verbose plots, etc.