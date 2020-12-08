#include <stdio.h>
#include <math.h>
#include "router.h"
static void print_hello()
{
	printf("Hello world!\n");

	double e = 0, tmp = 1;
	for (int i = 1; i <= 20; i++)
	{
		e += tmp;
		tmp /= i;
	}
	printf("e = %.15lf\n", e);
	printf("pi = 2 * atan2(1, 0) = %.15lf\n", 2 * atan2(1, 0));
}

int main()
{
	print_hello();
	lookup_test();
	return 233;
}
