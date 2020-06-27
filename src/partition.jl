# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EmpiricalVariogram(partition, var₁, var₂=var₁; [parameters])

Compute the empirical (cross-)variogram of the spatial `partition` for
variables `var₁` and `var₂`.

## References

* Hoffimann, J and Zadrozny, B. 2019. [Efficient variography with partition variograms]
  (https://www.sciencedirect.com/science/article/pii/S0098300419302936)
"""
function EmpiricalVariogram(partition::SpatialPartition,
                            var₁::Symbol, var₂::Symbol=var₁; kwargs...)
  # retain spatial data with at least 2 points
  filtered = Iterators.filter(d -> npoints(d) > 1, partition)

  @assert !isempty(filtered) "invalid partition of spatial data"

  γ(d) = EmpiricalVariogram(d, var₁, var₂; kwargs...)
  reduce(merge, Map(γ), collect(filtered))
end

"""
    DirectionalVariogram(direction, sdata, var₁, var₂=var₁; dtol=1e-6, [parameters])

Computes the empirical (cross-)variogram for the variables `var₁` and `var₂` stored in
spatial data `sdata` along a given `direction`.

Optional parameters include the parameters for [`EmpiricalVariogram`](@ref) and the
parameters for [`DirectionPartitioner`](@ref).
"""
function DirectionalVariogram(direction::NTuple, sdata,
                              var₁::Symbol, var₂::Symbol=var₁;
                              dtol=1e-6, kwargs...)
  p = partition(sdata, DirectionPartitioner(direction; tol=dtol))
  EmpiricalVariogram(p, var₁, var₂; kwargs...)
end

"""
    PlanarVariogram(normal, sdata, var₁, var₂=var₁; ntol=1e-6, [parameters])

Computes the empirical (cross-)variogram for the variables `var₁` and `var₂` stored in
spatial data `sdata` along a plane perpendicular to a `normal` direction.

Optional parameters include the parameters for [`EmpiricalVariogram`](@ref) and the
parameters for [`PlanePartitioner`](@ref).
"""
function PlanarVariogram(normal::NTuple, sdata,
                         var₁::Symbol, var₂::Symbol=var₁;
                         ntol=1e-6, kwargs...)
  p = partition(sdata, PlanePartitioner(normal; tol=ntol))
  EmpiricalVariogram(p, var₁, var₂; kwargs...)
end
