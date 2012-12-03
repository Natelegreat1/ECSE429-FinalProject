/*States*/
#define CLOSED 0
#define LISTEN 1
#define SYN_RCVD 2
#define SYN_SENT 3
#define ESTABLISHED_CONNECTION 4
#define FIN_WAIT_1 5
#define FIN_WAIT_2 6
#define TIMED_WAIT 7
#define CLOSING 8
#define CLOSE_WAIT 9
#define LAST_ACK 10

/*Message Types*/
mtype = {SYN, FIN, ACK, DATA};

/*timestamps*/
int seq_A = 0;
int ack_A = 0;
int seq_B = 0;
int ack_B = 0;

/*Channels*/
//chan hostA_internet = [2] of {mtype, int};
//chan hostB_internet = [2] of {mtype, int};
chan channel = [2] of {mtype, int}

/*States of Processes*/
byte hostA_state = CLOSED;
byte hostB_state = CLOSED;

/*Storage for received messages*/
int rcv_A;
int rcv_B;
int internet_msg;


/*Used to implement time out*/
int Timer_A = 0;

proctype HostA() //ROLE = CLIENT
{
	byte hostA_state = CLOSED;
	hostA_msg = 0;
	do
	::
		if
		::(hostA_state == CLOSED)->
			atomic
				{
					hostA_internet!SYN,seq;
					hostA_state = SYN_SENT;
					seq++;
				}
		
		::(hostA_state == LISTEN)->
		
		::(hostA_state == SYN_RCVD)->

		::(hostA_state == SYN_SENT)->

		::(hostA_state == ESTABLISHED_CONNECTION)->
			
		::(hostA_state == FIN_WAIT_1)->
			ack_A++;
			seq_A++;
			channel!ACK, ack_A;
			channel!FIN, seq_A;
			hostA_state = FIN_WAIT_2;				
				
		::(hostA_state == FIN_WAIT_2)->
				channel?ACK, ack_A;
				channel?FIN, seq_A;
				ack_A++;
				channel!ACK, ack_A;
			
		::(hostA_state == TIMED_WAIT)->
			
		::(hostA_state == CLOSING)->
			
		::(hostA_state == CLOSE_WAIT)->
			
		::(hostA_state == LAST_ACK)->
			
		fi;
	od;
	
}

proctype HostB() //ROLE = SERVER
{
	byte hostB_state = CLOSED;
	hostB_msg = 0;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
			hostA_state = LISTEN;

		::(hostB_state == LISTEN)->
			hostA_internet?SYN,seq_A

		::(hostB_state == SYN_RCVD)->
			
		::(hostB_state == SYN_SENT)->
			
		::(hostB_state == ESTABLISHED_CONNECTION)->
			
		::(hostB_state == FIN_WAIT_1)->
			
		::(hostB_state == FIN_WAIT_2)->
			
		::(hostB_state == TIMED_WAIT)->
			
		::(hostB_state == CLOSING)->
			
		::(hostB_state == CLOSE_WAIT)->
				channel?ACK, ack_B;
				channel?FIN, seq_B;
				ack_B++;
				seq_B++;
				channel!ACK, ack_B;
				channel!FIN, seq_A;
				
				hostB_state = LAST_ACK;
		::(hostB_state == LAST_ACK)->
				channel?ACK, ack_B;
				
				hostB_state = CLOSED;
		fi;
	od;
	
	
}

proctype Internet()
{




}


init
{
	run HostA();
	run HostB();
	proctype Internet();

}