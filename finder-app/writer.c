/*
 * File : writer.c
 *
 * Copyright (c) 2025
 *
 */
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>
#include <syslog.h>

#define NUMOFARGS 3

int main(int argc, char *argv[])
{
	FILE *fp = NULL;

	if (argc != 3) {
		openlog("writer", LOG_PID, LOG_USER);
		syslog(LOG_ERR, "Invalid number of arguments: expected 2, got %d", argc - 1);
		closelog();
		fprintf(stderr, "Usage: %s <filepath> <string>\n", argv[0]);
		return 1;
	}

	fp = fopen(argv[1], "w");
	if (fp) {
		if(fprintf(fp, "%s", argv[2]) < 0) {
			openlog("writer", LOG_PID, LOG_USER);
			syslog(LOG_ERR, "Failed to write to file: %s", argv[1]);
			closelog();
			perror("fprintf");
			fclose(fp);
			return 1;
		} else {
			openlog("writer", LOG_PID, LOG_USER);
			syslog(LOG_DEBUG, "Writing '%s' to '%s'", argv[2], argv[1]);
			closelog();
			return 0;
		}
	} else {
		openlog("writer", LOG_PID, LOG_USER);
		syslog(LOG_ERR, "Failed to open file: %s", argv[1]);
		closelog();
		perror("fopen");
		return 1;
	}

	return 0;
}
