global class StorybankPostInstallClass implements InstallHandler {
  global void onInstall(InstallContext context) {
    if(context.previousVersion() == null) {
      StorybankInstallationScripts.execute();
      }
      
      }
   
} //end class