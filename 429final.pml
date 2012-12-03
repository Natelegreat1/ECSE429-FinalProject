/*States*/
#define CLOSED 0
#define LISTEN 1
#define SYN_RCVD 2
#define SYN_SENT 3
#define ESTABLISHED_CONNECTION 4
#define FIN_WAIT_1 5
#define FIN_WAIT_2 6
#define TIME_WAIT 7
#define CLOSING 8
#define CLOSE_WAIT 9
#define LAST_ACK 10

/*Message Types*/
mtype = {SYN, FIN, ACK, DATA};

/*timestamps*/
int seq_A = 0;
int seq_B = 0;

int ack_A = 0;
int ack_B = 0;

/*Channels*/
//chan hostA_internet = [2] of {mtype, int};
//chan hostB_internet = [2] of {mtype, int};
chan channel = [2] of {mtype,int};

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
				channel!SYN,seq_A;
				hostA_state = SYN_SENT;
				seq_A++;
			}
		::(hostA_state == LISTEN)->
			//only server		
		::(hostA_state == SYN_RCVD)->
			//only server 
		::(hostA_state == SYN_SENT)->
			atomic
			{
				channel?ACK,rcv_A;
				seq_A = rcv_A;//check if rcv = seq later
				channel?SYN,rcv_A;
				ack_A = rcv_A +1;//dont do a check on the first seq from B received
				channel!ACK,ack_A;
				channel!SYN,seq_A;
				hostA_state = ESTABLISHED_CONNECTION;
			}
		::(hostA_state == ESTABLISHED_CONNECTION)->
	
		::(hostA_state == FIN_WAIT_1)->
			atomic
			{
				ack_A++;
				seq_A++;
				channel!ACK, ack_A;
				channel!FIN, seq_A;
			}
			hostA_state = FIN_WAIT_2;					
		::(hostA_state == FIN_WAIT_2)->
			atomic
			{
				channel?ACK, ack_A;
				channel?FIN, seq_A;
				ack_A++;
				channel!ACK, ack_A;
			}
			hostA_state = TIME_WAIT;
		::(hostA_state == TIME_WAIT)->
				if
				:: goto TIMEOUT;
				:: //stay put
				fi;
		::(hostA_state == CLOSING)->
			//if CLOSE comes from ESTABLISHED_CONNECTION
			
		fi;
	od;
	
	TIMEOUT:
	printf ("DONE");
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
			atomic
			{
				channel?SYN,rcv_B;
				ack_B = rcv_B+1;//dont check value of ack because its the first ack sent
				channel!ACK,ack_B;//sent ack back first 
				channel!SYN,seq_B;//then send syn
				hostB_state = SYN_RCVD;
			}
		::(hostB_state == SYN_RCVD)->
			atomic
			{
				channel?ACK,rcv_B;
				seq_B = rcv_B;
				channel?SYN,rcv_B;
				ack_B = rcv_B + 1;
				hostB_state = SYN_RCVD;
			}
		::(hostB_state == SYN_SENT)->
			
		::(hostB_state == ESTABLISHED_CONNECTION)->
			
			
		::(hostB_state == CLOSE_WAIT)->
			atomic
			{
				channel?ACK, ack_B;
				channel?FIN, seq_B;
				ack_B++;
				seq_B++;
				channel!ACK, ack_B;
				channel!FIN, seq_A;
			}
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


//control flow graph
//edge coverage
//node coverage
