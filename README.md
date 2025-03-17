# Recursive Least Squares (RLS) Identification in MATAB

An algorithm for Recursive Least Squares (RLS) model parameters identification using MATLAB.

This project provides a MATLAB implementation of the Recursive Least Squares (RLS) algorithm for identifying system parameters. The algorithm is designed to estimate the parameters of a discrete-time transfer function model based on input and output data.

## Features

- **Parameter Identification**: Identify the system parameters for a given system input and output using the RLS method.
- **Data Preprocessing**: Preprocess data based on step changes of the manipulated variable and conduct centralization and normalization.
- **Plotting**: Visualize the convergence of parameters and compare the actual and estimated system outputs.

## Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/MarekWadinger/RLS_identification.git
    ```

2. Navigate to the project directory:

    ```sh
    cd RLS_identification
    ```

## Usage

1. Load your data into MATLAB. The data should be in a structure with fields `t` (time), `u` (input), and `y` (output).
2. Preprocess the data:

    ```matlab
    [u_mean, y_mean, idx] = preprocessData(data);
    ```

3. Identify the system parameters:

    ```matlab
    Ts = 0.01;
    idtf = recursiveLeastSquares(u_mean, y_mean, Ts, 1, 2, 'PlotConv', true);
    ```

## Example

Here is an example of how to use the provided functions:

```matlab
%% Load file
load("example_fan_control.mat");

%% Make preprocessing
[u_mean, y_mean, idx] = preprocessData(data);

%% Identify system parameters of the specified order 
Ts = 0.01;
idtf = recursiveLeastSquares(u_mean, y_mean, Ts, 1, 2, 'PlotConv', true);
```

## License

MIT License
