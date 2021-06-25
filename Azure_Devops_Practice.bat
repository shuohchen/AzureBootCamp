cd C:\Repos\EngSys\AzureBootcampContosoAds
git pull
rem Reset your local branch to make sure any changes made in your local branch are removed. This will ensure that everyone is starting from the same commit.
git reset --hard origin/bootcamp
rem Initialize the CoreXT environment from the C:\Repos\EngSys\AzureBootcampContosoAds root directory
.\init
rem test local build, -notest : tell quickbuild to build the solution without running any of the unit tests; -batmon: skips reporting the build status at //b
quickbuild -notest -batmon ""
rem run the unittest
quickbuild -batmon ""
rem Create a new local branch of your own derived from current branch
git checkout -b feature/shuohchen
rem check the current branch I am working in
git branch
rem check the status of your current branch
git status 
rem open visual studio,This automatic solution creation is driven by the configuration file dirs.proj
vsmsbuild dirs.proj
rem stage the file we have bug-fixed using add
git add src\ContosoAdsWeb\Infrastructure\WebConfiguration.cs
rem commit the bugfix
git commit -m "Committing the connection string"
rem Reset the file to unstage it
git reset HEAD src\ContosoAdsWeb\Infrastructure\WebConfiguration.cs
rem checkout the file to undo the change
git checkout src\ContosoAdsWeb\Infrastructure\WebConfiguration.cs
rem The git stash command takes the dirty state of your working directory -- your modified tracked files and staged changes -- and saves it on a stack of unfinished changes that you can reapply at any time. 
rem Using git stash apply will bring these changes back
git stash
rem Build the solution in Release configuration to create a package ready for deployment
rem This will output the Cloud Service package (cspkg) file and configuration (cscfg) to the directory out\Release-AMD64\ContosoAdsCloudService\app.publish\ in the AzureBootcampContosoAds repo
build /p:Configuration=Release
rem copy the required files
xcopy /y out\Release-AMD64\ContosoAdsCloudService\app.publish\ContosoAdsCloudService.cspkg out\Release-AMD64\ContosoAdsCloudService\app.publish\ContosoAdsCloudService.cspkg
