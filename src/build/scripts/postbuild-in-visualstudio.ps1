#
# postbuild_in_visualstudio.ps1
#
param(
		[Parameter(Mandatory=$true)]$solutionDir,
		[Parameter(Mandatory=$true)]$configuration,
		$scriptsPath = ($script:MyInvocation.MyCommand.Path) 
    )

$funDirs =  (Get-ChildItem -Path $solutionDir -Filter "function.json" -Recurse) | Split-Path  | Convert-Path 
Write-Host "Run postbuild script; Path: $($script:MyInvocation.MyCommand.Path)"
Write-Host "Run postbuild script; Prepare function dirs"

$funDirs | % {
	 $funDir = $_
	 Write-Host "Run postbuild script; Processing $funDir"
	 $src = [io.path]::combine($funDir, "deneblab.json")
	 if (-not (Test-Path $src)){continue}
	 $c = (Get-Content $src | Out-String | ConvertFrom-Json)
	 # add solution reference
	 # array 
	 Write-Host "Run postbuild script; Soulution refs"
	 $c.soulutionRef | % {
		# of custom objects
		$_.psobject.properties | % {
				$project = $_.Name
				$projectRefs = $_.Value
				# array 
				$projectRefs | % {
					 # of custom objects
					 $_.psobject.properties | % {
						$src1 = [io.path]::combine($solutionDir, $project,  $_.Name, $configuration) 
						$dst = [io.path]::combine($funDir, $_.Value) 
						if (-not (Test-Path $src1)){continue}
						if (-not (Test-Path $dst)){
							New-Item -Path $dst -ItemType Directory | out-null
						}
						Write-Host "Run postbuild script; Project: $project; Src: $src1; Dst: $dst"
						Copy-Item "$src1/*" -destination $dst -Force
					 	
					 }
				}
			 }
		 }
}



Write-Host "Run postbuild script; Done"

