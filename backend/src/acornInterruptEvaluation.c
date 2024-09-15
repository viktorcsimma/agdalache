#include "../include/Acorn.h"
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#else
#if defined(__unix__) || defined(__unix) || \
        (defined(__APPLE__) && defined(__MACH__))
#include <semaphore.h>
#include <stdlib.h>
#endif
#endif

// See Acorn.h for description.

#ifdef _WIN32
void acornInterruptEvaluation() {
  // here, we won't actually use the handle
  HANDLE eventHandle = OpenEventA(
    EVENT_MODIFY_STATE,
    FALSE,
    "AcornInterruptEvent"
  );
  BOOL success = SetEvent(eventHandle);
  CloseHandle(eventHandle);
  if (! success ) {
    CloseHandle(eventHandle);
    fprintf(stderr, "SetEvent failed (%lu)\n", GetLastError());
  }
}
#else
#if defined(__unix__) || defined(__unix) || \
        (defined(__APPLE__) && defined(__MACH__))
void acornInterruptEvaluation() {
  // opening the already existing semaphore
  sem_t* semaphore = sem_open("AcornInterruptSemaphore", 0);
  if (SEM_FAILED == semaphore) {
    fprintf(stderr, "Could not open semaphore\n");
  } else {
    sem_post(semaphore);
    // and we close it from our side, but do not remove it
    // (that will be done on the Haskell side)
    sem_close(semaphore);
  }
}
#endif
#endif
