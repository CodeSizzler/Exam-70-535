Configuration Main
{

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node "localhost"
{

	# Install the IIS role 
	WindowsFeature IIS 
	{ 
		Ensure          = "Present" 
		Name            = "Web-Server" 
	} 
	# Install the ASP .NET 4.5 role 
	WindowsFeature AspNet45 
	{ 
		Ensure          = "Present" 
		Name            = "Web-Asp-Net45" 
	} 
	   
	File WebContent 
	{ 
		Ensure          = "Present" 
		SourcePath      = "$PSScriptRoot\CloudShop"
		DestinationPath = "C:\Inetpub\wwwroot"
		Recurse         = $true 
		Type            = "Directory" 
		DependsOn       = "[WindowsFeature]IIS" 
	} 
  }
}