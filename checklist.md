## Checklist
- [X] Grep for "BioJuliaTemplate" and "YourName" and change the places they appear.
- [X] Replace the UUID in Project.toml with a freshly-generated one (`using UUIDs; uuid4()`)
- [ ] Generate a Documenter deploy key and secret, and upload them to your GitHub repo.
      See the docs of Documenter.jl to see how.
- [ ] Visit codecov.io and get a codecov secret token. Add to your GitHub repo under secrets
- [X] Adjust the minimal Julia version in Project.toml, then in .github/workflows/UnitTesting.yml.
- [X] Update the README.md
- [ ] Add code to the src directory
- [ ] Add tests to the test directory
- [ ] Add documentation to the docs directory
- [ ] Verify docs build locally and all doctests pass
- [ ] Trigger CI and iteratively add tests until you get good coverage
- [ ] Optionally run Aqua.jl
- [ ] Optionally add a PrecompileTools workload. See FASTX.jl for how to do this.
- [ ] Optionally use JET.jl to verify your workload is type stable.
