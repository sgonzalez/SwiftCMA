# SwiftCMA
## *by Santiago Gonzalez*
### ***A pure-Swift implementation of Covariance Matrix Adaptation Evolutionary Strategy (CMA-ES).***

**SwiftCMA** is a *de novo* implementation of [Covariance Matrix Adaptation Evolutionary Strategy](https://en.wikipedia.org/wiki/CMA-ES) (CMA-ES). CMA-ES is a wonderful population-based optimization technique that can optimize non-convex, non-smooth, non-differentiable functions. While CMA-ES is conceptually simple, it's rather complex mathematically. **SwiftCMA** is written in pure Swift, and makes proper use of functional programming and Swift's type system. This project is provided under the MIT License (see the `LICENSE` file for more info).

## Functionality

### CMA-ES

The specific implementation of CMA-ES is inspired by the MATLAB reference implementation on [Wikipedia](https://en.wikipedia.org/wiki/CMA-ES). The implementation supports arbitrarily-high dimension solution spaces.

The primary `CMAES` object has two slightly different implementations of the main `epoch()` method.
* One takes a closure that takes an array of candidate solution vectors and returns an array of corresponding objective function values. This allows your code to potentially calculate objective function values concurrently.
* Alternatively, for simplicity, you can use the flavor of `epoch()` that takes an objective evaluator. Objective functions can be represented by types that conform to the `ObjectiveEvaluator` protocol. In this case, objective function values are calculated sequentially on the same thread.

### Linear Algebra API

Swift isn't traditionally thought of as a good language for linear algebra code, though I feel that's mainly due to the lack of linear algebra APIs. **SwiftCMA** provides a clean API for vectors and matrices, based on top of Swift arrays, that should feel familiar if you've used Eigen / MATLAB / Octave, or similar systems. This API has not been optimized to be as fast as it could be since objective-function evaluation is the biggest bottleneck by far for what I created this library for (metalearning). Pull requests are welcome!

Features:
* Vectors and vector operations
* Matrices and matrix operations
* Vector-matrix operations
* Eigendecomposition of matrices to get eigenvalues and an eigenbasis
* Covariance matrix wrapper

### Unit Tests

Testing is great, so we have some unit tests as part of the Xcode project! More tests would be great, right now the tests just cover the linear algebra APIs.

### Built-in Objective Functions

**SwiftCMA** has some built-in objective functions. These are useful for testing / benchmarking how well the system is able to optimize some relatively well-understood functions.

* N-dimensional sphere: `SphereObjectiveEvaluator`
* Rastrigin function: `RastriginObjectiveEvaluator`
* Ackley function: `AckleyObjectiveEvaluator`

### Test App

**SwiftCMA** comes with an Xcode project that builds a test app bundle. All code specific to this is in the `App/` directory. A quick note: the project builds an app bundle, rather than a basic executable, since it needs to link to `Accelerate.framework`. Tests live in the `Tests/` directory.

## Usage

Everything you need to use **SwiftCMA** is in the `Sources/` directory.

```swift
let startSolution: Vector = ...
var fitness = MyObjectiveEvaluator()
let populationSize = CMAES.populationSize(forDimensions: startSolution.count)
let stepSigma: Double = ...

let cmaes = CMAES(startSolution: startSolution, populationSize: populationSize, stepSigma: stepSigma)
var bestSolution: (Vector, Double)?
for i in 0..<1000 {
	cmaes.epoch(evaluator: &fitness) { newSolution, newFitness in
		print("Found solution with fitness \(fitness): \(solution)")
	}

	if bestSolution == nil || bestSolution!.1 > cmaes.bestSolution!.1 {
		bestSolution = cmaes.bestSolution
	}
	print("\(i):   \(cmaes.bestSolution!.1)")
}

print("Best: \(bestSolution!.1): \(bestSolution!.0)")
```

### Defining an Objective Function

CMA-ES aims to find the global minimum, so your objective function must be formulated so that smaller values are better.

```swift
struct SphereObjectiveEvaluator: ObjectiveEvaluator {
	typealias Genome = Vector

	func objective(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let value = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.01 { // We have found a solution when the difference is below a threshold.
			solutionCallback(genome, diff)
		}
		return genome.squared.sum
	}
}
```

### Dependencies

The only external dependency is `LAPACK` (for eigendecomposition). On macOS, this is fulfilled by the built-in `Accelerate` framework. On Linux, you should use the [CLapacke-Linux](https://github.com/indisoluble/CLapacke-Linux) Swift wrapper around `LAPACK`, which is very easy to install using APT.


## Future Work

* Integrate with Swift Package Manager.
* Separate linear algebra API into its own library.
* Faster.
* Support fun variants of CMA-ES.
* More tests (unit, integration, performance).
* More engaging test app that visualizes the CMA-ES process.
