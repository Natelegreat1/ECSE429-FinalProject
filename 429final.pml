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
chan A_to_B = [2] of {mtype,int};
chan B_to_A = [2] of {mtype,int};

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
	hostA_state = CLOSED;
	rcv_A = 0;
	do
	::
		if
		::(hostA_state == CLOSED)->
			atomic
			{
				A_to_B!SYN,seq_A;
				hostA_state = SYN_SENT;
				seq_A++;
			}
		::(hostA_state == SYN_SENT)->
			atomic
			{
				B_to_A?ACK,rcv_A;
				seq_A = rcv_A;//check if rcv = seq later
				B_to_A?SYN,rcv_A;
				ack_A = rcv_A +1;//dont do a check on the first seq from B received
				A_to_B!ACK,ack_A;
				A_to_B!SYN,seq_A;
				hostA_state = ESTABLISHED_CONNECTION;
			}
		::(hostA_state == ESTABLISHED_CONNECTION)->
			atomic
			{
				//close
				A_to_B!FIN,seq_A;
				hostA_state = FIN_WAIT_1;
			}
		::(hostA_state == FIN_WAIT_1)->
			atomic
			{
				B_to_A?ACK,ack_A;
				hostA_state = FIN_WAIT_2;	
			}				
		::(hostA_state == FIN_WAIT_2)->
			atomic
			{
				B_to_A?FIN,seq_A;
				ack_A = seq_A+1;
				A_to_B!ACK, ack_A;
				hostA_state = TIME_WAIT;
			}
		::(hostA_state == TIME_WAIT)->
			atomic
			{
				B_to_A?ACK,ack_A;
				hostA_state = CLOSED;
				break;//to finish process
			}
		::(hostA_state == CLOSING)->
			skip;//if CLOSE comes from ESTABLISHED_CONNECTION
		fi;
	od;
}
proctype HostB() //ROLE = SERVER
{
	hostB_state = CLOSED;
	rcv_B = 0;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
			hostB_state = LISTEN;
		::(hostB_state == LISTEN)->
			atomic
			{
				A_to_B?SYN,rcv_B;
				ack_B = rcv_B+1;//dont check value of ack because its the first ack sent
				B_to_A!ACK,ack_B;//sent ack back first 
				B_to_A!SYN,seq_B;//then send syn
				hostB_state = SYN_RCVD;
			}
		::(hostB_state == SYN_RCVD)->
			atomic
			{
				A_to_B?ACK,rcv_B;
				seq_B = rcv_B;
				A_to_B?SYN,rcv_B;
				ack_B = rcv_B + 1;
				hostB_state = ESTABLISHED_CONNECTION;
			}
		::(hostB_state == ESTABLISHED_CONNECTION)->
			atomic
			{
				A_to_B?FIN,seq_B;
				ack_B = seq_B +1;
				B_to_A!ACK,ack_B;
				hostB_state = CLOSE_WAIT;
			}
		::(hostB_state == CLOSE_WAIT)->
			atomic
			{
				//close
				B_to_A!FIN, seq_A;
				hostB_state = LAST_ACK;
			}
		::(hostB_state == LAST_ACK)->
			atomic
			{
				A_to_B?ACK, ack_B;
				hostB_state = CLOSED;
				break;//to finish process
			}
		fi;
	od;
}

//proctype Internet()
//{
//}


init
{
	run HostA();
	run HostB();
	//proctype Internet();
}


//control flow graph
//edge coverage
//node coverage
