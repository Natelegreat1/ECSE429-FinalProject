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

/*Macros for LTL assertions*/

/*Host A FSM behaviour*/
#define hostA_state==CLOSED 				AC
#define hostA_state==SYN_SENT 				ASS
#define hostA_state==ESTABLISHED_CONNECTION	AEC
#define hostA_state==FIN_WAIT_1				AFW1
#define hostA_state==FIN_WAIT_2				AFW2
#define hostA_state==TIME_WAIT				ATW


/*Host B FSM behaviour*/
#define hostB_state==CLOSED 				BC
#define hostB_state==LISTEN 				BL
#define hostB4_state==SYN_RCVD 				BSR
#define hostB_state==ESTABLISHED_CONNECTION	BEC
#define hostB_state==CLOSE_WAIT				BCW
#define hostB_state==LAST_ACK				BLA

/*Message Types*/
mtype = {SYN, FIN, ACK, DATA};

/*timestamps*/
int seq_A = 0;
int seq_B = 100;

int ack_A;
int ack_B;

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
int rcv_type_B;
//int internet_msg;


/*Used to implement retransmission*/
int TIMEOUT = 5;
bool received = false;
int time = 0;

proctype HostA()
{
	hostA_state = CLOSED; // hostA_state = ESTABLISHED_CONNECTION; //MUTATION_01
	rcv_A = 0;
	do
	::
		if
		::(hostA_state == CLOSED)->
			atomic
			{
				printf("seq: %d\n",seq_A);
				A_to_B!SYN,seq_A;
				hostA_state = SYN_SENT; // hostA_state = ESTABLISHED_CONNECTION; //MUTATION_02
			}
		::(hostA_state == SYN_SENT)->
			atomic
			{
				B_to_A?ACK,rcv_A;
				seq_A = rcv_A;//check if rcv = seq later
				B_to_A?SYN,rcv_A;
				ack_A = rcv_A +1;//dont do a check on the first seq from B received
				printf("ack: %d\n",ack_A);
				A_to_B!ACK,ack_A;
				hostA_state = ESTABLISHED_CONNECTION; // hostA_state = CLOSING; //MUTATION_03
			}
		::(hostA_state == ESTABLISHED_CONNECTION)->		
			received = false;
			if
			::			
				//send data
				do
				::(received == false)->
					atomic
					{
						if 
						::(time % TIMEOUT == 0)->
								printf("seq: %d\n",seq_A);
								A_to_B!DATA,seq_A;
								printf("Send!\n");
						::else->
							printf("Hello?\n");
						fi;
						time++;	
					}
				::else->
					break;
				od;
				atomic
				{
					printf("Received!\n");
					B_to_A?ACK,rcv_A;
					seq_A = rcv_A;
					time = 0;
				}
			::
				atomic
				{
					//close
					printf("seq: %d\n",seq_A);
					A_to_B!FIN,seq_A;
					hostA_state = FIN_WAIT_1; // hostA_state = CLOSED //MUTATION_04
				}
			fi;
		::(hostA_state == FIN_WAIT_1)->
			atomic
			{
				B_to_A?ACK,ack_A;
				hostA_state = FIN_WAIT_2; // hostA_state = CLOSED; //MUTATION_05	
			}				
		::(hostA_state == FIN_WAIT_2)->
			atomic
			{
				B_to_A?FIN,rcv_A;
				ack_A = rcv_A+1;
				printf("ack: %d\n",ack_A);
				A_to_B!ACK, ack_A;
				hostA_state = TIME_WAIT; // hostA_state = CLOSING; //MUTATION_06
			}
		::(hostA_state == TIME_WAIT)->
			atomic
			{
				//timeout
				hostA_state = CLOSED; // hostA_state = ESTABLISHED_CONNECTION; //MUTATION_07
				break;//to finish process
			}
		::(hostA_state == CLOSING)->
			skip;//if CLOSE comes from ESTABLISHED_CONNECTION
		fi;
	od;
}
proctype HostB()
{
	hostB_state = CLOSED; // hostB_state = SYN_RCVD; //MUTATION_08
	rcv_B = 0;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
			hostB_state = LISTEN; // hostB_state = ESTABLISHED_CONNECTION; //MUTATION_09
		::(hostB_state == LISTEN)->
			atomic
			{
				A_to_B?SYN,rcv_B;
				ack_B = rcv_B+1;//dont check value of ack because its the first ack sent
				printf("ack: %d\n",ack_B);
				printf("seq: %d\n",seq_B);
				B_to_A!ACK,ack_B;//sent ack back first 
				B_to_A!SYN,seq_B;//then send seq B for first time
				hostB_state = SYN_RCVD; // hostB_state = ESTABLISHED_CONNECTION; //MUTATION_10
			}
		::(hostB_state == SYN_RCVD)->		
			atomic
			{
				A_to_B?ACK,rcv_B;
				seq_B = rcv_B;
				hostB_state = ESTABLISHED_CONNECTION; // hostB_state = LAST_ACK; //MUTATION_11
			}
		::(hostB_state == ESTABLISHED_CONNECTION)->
			A_to_B?rcv_type_B,rcv_B;
			received = true;
			atomic
			{
				ack_B = rcv_B+1;
				printf("ack: %d\n",ack_B);
				B_to_A!ACK,ack_B;
				if
				::(rcv_type_B == FIN)->
					hostB_state = CLOSE_WAIT; // hostB_state = CLOSED; //MUTATION_12
				:: else->
					skip;
				fi;			
			}
		::(hostB_state == CLOSE_WAIT)->
		atomic
		{
			//close
			printf("seq: %d\n",seq_B);
			B_to_A!FIN, seq_B;
			hostB_state = LAST_ACK; // hostB_state = CLOSED; //MUTATION_13
		}
		::(hostB_state == LAST_ACK)->
			atomic
			{
				A_to_B?ACK, rcv_B;
				seq_B = rcv_B;
				hostB_state = CLOSED; // hostB_state = ESTABLISHED_CONNECTION; //MUTATION_14
				break;//to finish process
			}
		fi;
	od;
}



init
{
	run HostA();
	run HostB();
}


//control flow graph
//edge coverage
//node coverage
