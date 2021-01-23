/*-------------------------------------------------------------------------
 *
 * system_proxy.h
 *        Replacement for the system() function.
 *
 * This file must be included by all Postgres modules that would make use
 * of the system() function.
 *
 *
 * Portions Copyright (c) 1996-2021, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/include/system_proxy.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef SYSTEM_PROXY_H
#define SYSTEM_PROXY_H

/*
 * Replacement for the system() function.
 * The system() function is marked unavailable on some Apple platforms,
 * so we need to substitute it there.
 */
int system_proxy(const char *cmd);

#endif                                                  /* SYSTEM_PROXY_H */

