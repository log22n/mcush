/* MCUSH designed by Peng Shulin, all rights reserved. */
#ifndef _TASK_DHCPC_H_
#define _TASK_DHCPC_H_


#define TASK_DHCPC_STACK_SIZE        (2*1024 / sizeof(portSTACK_TYPE))
#define TASK_DHCPC_PRIORITY          (MCUSH_PRIORITY - 1)
#define TASK_DHCPC_QUEUE_SIZE  (4)


#define DHCPC_EVENT_NETIF_UP     1
#define DHCPC_EVENT_NETIF_DOWN   2
#define DHCPC_EVENT_CHECK_TIMER  3

void send_dhcpc_event(uint8_t event); 

void task_dhcpc_init(void);

#endif

