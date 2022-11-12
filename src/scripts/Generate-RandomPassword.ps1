$letterCodes = (65..90) + (97..122)
$numberCodes = (48..57)
$symbolCodes = (33, 35, 36, 37, 42, 43, 63, 64, 94)
$randomChars = $letterCodes + $numberCodes + $symbolCodes | Get-Random -Count 32 | Foreach-Object { [char] $_ }
$randomString = (-Join $randomChars)

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['Result'] = $randomString