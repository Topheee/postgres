/*-------------------------------------------------------------------------
 *
 * system_proxy.c
 *			  Proxy function to system()
 *
 *
 * Copyright (c) 1996-2021, PostgreSQL Global Development Group
 *
 *
 * IDENTIFICATION
 *		src/port/system_proxy.c
 *
 *-------------------------------------------------------------------------
 */


#ifndef FRONTEND
#include "postgres.h"
#else
#include "postgres_fe.h"
#endif

#include "port/system_proxy.h"

#if defined(__APPLE__)
#include <TargetConditionals.h>
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV

#define EMULATE_SYSTEM_FUNCTION 1

#endif
#endif

#ifdef EMULATE_SYSTEM_FUNCTION
// replace system() function, as it is unavailable on iOS, tvOS, watchOS

#include <spawn.h>
#include <stdlib.h>
#include <string.h>

extern char **environ;

static int emulate_system(char *cmd)
{
	pid_t pid;
	char *const argv[] = {"sh", "-c", cmd, NULL};
	int status;

	status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
	if (status == 0) {
		if (waitpid(pid, &status, 0) == -1) {
			return -1;
		}
	}
	return status;
}

int system_proxy(const char *cmd)
{
	return emulate_system((char *)cmd);
}

#else
int system_proxy(const char *cmd)
{
	return system(cmd);
}
#endif

