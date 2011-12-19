(*===========================================================================

  DESCRIPTION:
  This module is part of the run time system for the 32-bit Oberon-2 compiler.
  It contains the entry point function for the DLL-version of the run time 
  system.
  
  AUTHORS:     
  Peter René Dietmüller (PDI)
  
  COPYRIGHT:   
  FIM (Forschungsinstitut für Mikroprozessortechnik),  University of Linz
  
 ============================================================================
  DATE      AUTHOR  CHANGES
  --------  ------  -------------------------------------------------------
  97/07/21  PDI     First version
 ===========================================================================*)
MODULE RTSDLL;

  IMPORT RTSOberon, W := RTSWin;


(*===========================================================================
  This is the entry point for the DLL version of the runtime system. It is
  called when the DLL is load or another process starts which uses this
  DLL.
 ============================================================================
  PARAMETER  DESCRIPTION
  ---------  ----------------------------------------------------------------
  hInstDLL   A handle to the DLL. The value is the base address of the DLL. 
             The HINSTANCE of a DLL is the same as the HMODULE of the DLL, 
             so hinstDLL can be used in subsequent calls to the 
             GetModuleFileName function and other functions that require a 
             module handle. 
  fdwReason  Specifies a flag indicating why the DLL entry-point function is 
             being called. This parameter can be one of the following values: 
             DLL_PROCESS_ATTACH 
             DLL_THREAD_ATTACH 
             DLL_THREAD_DETACH 
             DLL_PROCESS_DETACH 
 lpvReserved Specifies further aspects of DLL initialization and cleanup. 
             If fdwReason is DLL_PROCESS_ATTACH, lpvReserved is NULL for 
             dynamic loads and non-NULL for static loads. 
             If fdwReason is DLL_PROCESS_DETACH, lpvReserved is NULL if 
             DllEntryPoint has been called by using FreeLibrary and non-NULL 
             if DllEntryPoint has been called during process termination.  
 ===========================================================================*)
PROCEDURE [_APICALL] DllEntryPoint*(hInstDLL:    W.HINSTANCE;
                                    fdwReaseon:  W.DWORD; 
                                    lpvReserved: W.LPVOID): W.BOOL;
BEGIN
  RETURN 1;
END DllEntryPoint;

END RTSDLL.
