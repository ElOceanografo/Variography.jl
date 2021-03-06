@testset "Fitting" begin
  wl = geostatsimage("WalkerLake")
  TI = reshape(wl[:Z], size(domain(wl)))[1:20,1:20]
  d = georef((z=TI,))
  γwalker = EmpiricalVariogram(d, :z, maxlag=15.)

  # variogram types to fit
  Vs = (GaussianVariogram, SphericalVariogram,
        ExponentialVariogram, MaternVariogram)

  # all fits lead to same sill
  γs = [fit(V, γwalker) for V in Vs]
  for γ in γs
    @test isapprox(sill(γ), 0.054, atol=1e-3)
  end

  # best fit is a Gaussian variogram
  γbest = fit(Variogram, γwalker)
  @test γbest isa GaussianVariogram
  @test isapprox(sill(γbest), 0.054, atol=1e-3)

  if visualtests
    @plottest begin
      plts = []
      for γ in γs
        plt = plot(γwalker, legend=false)
        plot!(γ, 0., 15.)
        push!(plts, plt)
      end
      plot(plts...)
    end joinpath(datadir,"fitting.png") !istravis
  end
end
