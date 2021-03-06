
# 1.0.0.beta.7

  * fixed bug where local packages that are indirect dependencies of other 
    remote packages could cause bpm to error out unable to find dependencies.
    
  * improved logging slightly
  
# 1.0.0.beta.6 (yanked)

  * bpm now passes a context object with build settings and a minify option
    to plugins - this will allow spade to support string loading.
  
# 1.0.0.beta.5

  * bpm list now shows local dependencies by default.  Use bpm list --remote
    to get remote.
  * better compatibility with npm - "summary" field is optional and "url" is
    mapped to "homepage"
  * fixed some failing unit tests
  * you can now place other projects into a vendor directory and have their 
    packages appear in the local package.  This is useful if you want to 
    import another project which holds multiple packages for development.
  
# 1.0.0.beta.4

  * Fixed issue with compile that would cause exceptions if you deleted the
    global .bpm directory
  * BPM now complains if you load a package whose directory name does not 
    match the name in the package.json (this was causing exceptions in some
    cases)
  * BPM is more whiny now when it tries to load a package with invalid or
    missing package.json.
  * the version stored in the `bpm` key on new projects is a compatible 
    version instead of the actual version.  Right now this means it is frozen
    at 1.0.0
  * merge `bpm new` into `bpm init`.  now this works like git.  If you
    `bpm init` on an existing directory, bpm will try to update it.  If you
    `bpm init` and pass a new path, bpm will create it.
  * now showing version of bpm in bpm help

# 1.0.0.beta.3.pre

  * started changelog
  