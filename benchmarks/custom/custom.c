/*Custom benchmark adding numbers*/
#include <stdio.h>
#include "hal.h"


int main()
{
   	long a, b, c;
	int i;
	for (i=0; i<100; i++)
	{
		a+=1000*i;
		b+=500*i;
		c=a+b;
	}
	return 0;
}
