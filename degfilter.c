/* degfilter.c — pass through graph6 lines (n<=12) whose graphs have at most
 * MAXDEG_CLASSES distinct degree values. Necessary condition for having at
 * most that many vertex-deleted card types (isomorphic cards => equal
 * deleted-vertex degrees). Prints survivors to stdout; count summary to
 * stderr. */
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define MAXN 12
#define MAXDEG_CLASSES 3

int main(void) {
    char line[64];
    long total = 0, kept = 0;
    while (fgets(line, sizeof line, stdin)) {
        size_t L = strlen(line);
        while (L && (line[L-1] == '\n' || line[L-1] == '\r')) line[--L] = 0;
        if (!L) continue;
        int n = line[0] - 63;
        if (n < 1 || n > MAXN) continue;
        total++;
        int deg[MAXN] = {0};
        int bitpos = 0;
        const char *p = line + 1;
        for (int j = 1; j < n; j++)
            for (int i = 0; i < j; i++, bitpos++) {
                int byte = bitpos / 6, off = 5 - bitpos % 6;
                if (((p[byte] - 63) >> off) & 1) { deg[i]++; deg[j]++; }
            }
        uint16_t seen = 0;
        int classes = 0;
        for (int v = 0; v < n; v++)
            if (!((seen >> deg[v]) & 1)) { seen |= (uint16_t)(1u << deg[v]); classes++; }
        if (classes <= MAXDEG_CLASSES) { kept++; puts(line); }
    }
    fprintf(stderr, "degfilter: total=%ld kept=%ld\n", total, kept);
    return 0;
}
