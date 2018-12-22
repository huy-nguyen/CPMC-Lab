# Package CPMC-Lab version 1.0 (2014)

## Authors

Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang

Package homepage: [huynguyen.io/CPMC-Lab](https://www.huynguyen.io/CPMC-Lab).


## Licensing

- This package is distributed under the [Computer Physics Communications Non-Profit Use License](http://cpc.cs.qub.ac.uk/licence/licence.html).

- Any publications resulting from either applying or building on the present package should cite the following journal article (in addition to the relevant literature on the method): *CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations*, Comput. Phys. Commun. **185**, 3344 (2014).

## Package Overview

- CPMC-Lab is a Matlab package for the constrained-path and phaseless auxiliary-field Monte Carlo methods. This package implements the full ground-state constrained-path Monte Carlo (CPMC) method in Matlab with a graphical interface, using the Hubbard model as an example.

- The package can perform calculations in finite supercells in any dimensions, under periodic or twist boundary conditions. The package also includes and illustrates importance sampling and all other algorithmic details of a total energy calculation. This open-source tool allows users to experiment with various model and run parameters and visualize the results. It provides a direct and interactive environment to learn the method and study the code with minimal overhead for setup.

- Furthermore, the package can be easily generalized for auxiliary-field quantum Monte Carlo (AFQMC) calculations in many other models for correlated electron systems, and can serve as a template for developing a production code for AFQMC total energy calculations in real materials.


## Installation and Execution

- User must have an active Matlab installation to run the CPMC-Lab package. The GUI (but not the rest of the package) requires Matlab R2010b (version 7.11) or above. For installation instructions, visit <http://www.mathworks.com/help/install>.

- To run the sample script `sample.m` in an interactive Matlab session, navigate to the directory containing the script, type `sample` and hit Enter or Return. User should feel free to change the input parameters in `sample.m` and run the script with these new parameters.

- For help, see the header of each file in the package. Alternatively, in an interactive Matlab session, type `help filename` at the Matlab prompt.

## Content Description:

This package contains 10 source files for the CPMC program, 1 GUI program, and 2 sample scripts for running the program:

- `CPMC_Lab.m` is the main driver of the package. For every time step, it calls `stepwlk.m` to propagate the walkers. When appropriate, it calls `measure.m` to measure the energy, `stlbz.m` to re-orthonormalize the walkers or `pop_cntrl.m` to do population control. After the end of the random walk, it calculates the final average and standard error of the energy and saves the results to a file.

- `initialization.m` runs `validation.m` to conduct a basic check on the input parameters and initializes internal quantities, e.g. the total number of sites and electrons. It forms the free-electron trial wave function and creates the initial population of walkers.

- `validation.m` verifies the basic validity of user inputs, as mentioned above.

- `H_K.m` creates the one-body kinetic Hamiltonian.

- `stepwlk.m`  carries out one step of the random walk by calling `halfK.m`, `V.m` and `halfK.m` again.

- `halfK.m` propagates a walker by exp(-Delta tau K/2).

- `V.m` carries out importance sampling site by site to select the auxiliary fields, and propagates a walker by exp(-Delta tau V).

- `measure.m` computes the energy of a walker.

- `stblz.m` orthonormalizes walkers by the modified Gram-Schmidt algorithm.

- `pop_cntrl.m` carries out population control by a simple-combing method.

- `sample.m` is a script that allows users to set input parameters.

- `batchsample.m` is a script that loops over multiple sets of parameters.

- `GUI.m` launches the graphical user interface of the package. It is a stand-alone file that is independent of all the other files in the package and contains all the subroutines of a QMC run.

## Sample Input

Sample input can be found in the script `sample.m`.

## Sample output:

The following output is produced by running the `sample.m` script as distributed. If invoked during an interactive session, this output is displayed in the Matlab command window. A `*.mat` file containing all data from the calculation is also saved to the script's directory.(Below we have left the actual output values blank, since they depend on the particular random number generator seed.)

\>\> sample

E(1)= ...

E(2)= ...

E(3)= ...

...

E_ave =  ...


E_err =  ...


time =  ...
