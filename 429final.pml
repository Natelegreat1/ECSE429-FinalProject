/*States*/
#define CLOSED 					0
#define LISTEN 					1
#define SYN_RCVD 				2
#define SYN_SENT 				3
#define ESTABLISHED_CONNECTION 	4
#define FIN_WAIT_1 				5
#define FIN_WAIT_2 				6
#define TIME_WAIT 				7
#define CLOSING 				8
#define CLOSE_WAIT 				9
#define LAST_ACK 				10

/*Macros for LTL assertions*/

/*Host A FSM behaviour*/
#define AC 		hostA_state==CLOSED 
#define ASS 	hostA_state==SYN_SENT 
#define AEC 	hostA_state==ESTABLISHED_CONNECTION
#define AFW1 	hostA_state==FIN_WAIT_1	
#define AFW2 	hostA_state==FIN_WAIT_2
#define ATW 	hostA_state==TIME_WAIT


/*Host B FSM behaviour*/
#define BC 		hostB_state==CLOSED 		
#define BL 		hostB_state==LISTEN 
#define BSR 	hostB_state==SYN_RCVD 
#define BEC 	hostB_state==ESTABLISHED_CONNECTION
#define BCW 	hostB_state==CLOSE_WAIT	
#define BLA 	hostB_state==LAST_ACK	

/*Message Types*/
mtype = {SYN, FIN, ACK, DATA};

/*timestamps*/
int seq_A = 0;
int seq_B = 100;

int ack_A;
int ack_B;

/*Channels*/
chan A_to_I = [2] of {mtype,int};
chan I_to_B = [2] of {mtype,int};
chan B_to_A = [2] of {mtype,int};


/*States of Processes*/
byte hostA_state = 		CLOSED;
byte hostB_state = 		CLOSED;
byte internet_state = 	CLOSED;

/*Storage for received messages*/

/*HostA*/
int rcv_A;

/*HostB*/
int rcv_B;
int rcv_type_B;

/*Internet*/
int rcv_I;
int rcv_type_I;

/*Used to implement retransmission*/
int TIMEOUT = 5;
bool received = false;
int timer;

proctype HostA()
{
	hostA_state = CLOSED; // hostA_state = ESTABLISHED_CONNECTION; //MUTANT_01
	rcv_A = 0;
	do
	::
		if
		::(hostA_state == CLOSED)->
			atomic
			{
				printf("seq: %d\n",seq_A);
				A_to_I!SYN,seq_A;
				hostA_state = SYN_SENT; // hostA_state = ESTABLISHED_CONNECTION; //MUTANT_02
			}
		::(hostA_state == SYN_SENT)->
			atomic
			{
				B_to_A?ACK,rcv_A;
				seq_A = rcv_A;//check if rcv = seq later
				B_to_A?SYN,rcv_A;
				ack_A = rcv_A + 1;//dont do a check on the first seq from B received
				//ack_A = rcv_A + 2; //MUTANT_15
				printf("ack: %d\n",ack_A);
				A_to_I!ACK,ack_A;
				hostA_state = ESTABLISHED_CONNECTION; // hostA_state = CLOSING; //MUTANT_03
			}
		::(hostA_state == ESTABLISHED_CONNECTION)->		
			received = false;
			if
			::			
				//send data
				timer = 0;
				do
				::(received == false)->
					atomic
					{
						if 
						::(timer % TIMEOUT == 0)->
								printf("seq: %d\n",seq_A);
								A_to_I!DATA,seq_A;
								if
								::(timer == 0)->
									printf("Send!\n");
								::else->
									printf("Resend!\n");
								fi;
						::else->
							printf("Hello?\n");
						fi;
						timer++;	
					}
				::else->
					break;
				od;
				atomic
				{
					printf("you Received it didn't you!\n");
					B_to_A?ACK,rcv_A;
					seq_A = rcv_A;
				}
			::
				atomic
				{
					//close
					printf("seq: %d\n",seq_A);
					A_to_I!FIN,seq_A;
					hostA_state = FIN_WAIT_1; // hostA_state = CLOSED //MUTANT_04
				}
			fi;
		::(hostA_state == FIN_WAIT_1)->
			atomic
			{
				B_to_A?ACK,ack_A;
				hostA_state = FIN_WAIT_2; // hostA_state = CLOSED; //MUTANT_05	
			}				
		::(hostA_state == FIN_WAIT_2)->
			atomic
			{
				B_to_A?FIN,rcv_A;
				ack_A = rcv_A+1;
				printf("ack: %d\n",ack_A);
				A_to_I!ACK, ack_A;
				hostA_state = TIME_WAIT; // hostA_state = CLOSING; //MUTANT_06
			}
		::(hostA_state == TIME_WAIT)->
			atomic
			{
				//timeout
				hostA_state = CLOSED; // hostA_state = ESTABLISHED_CONNECTION; //MUTANT_07
				break;//to finish process
			}
		::(hostA_state == CLOSING)->
			skip;//if CLOSE comes from ESTABLISHED_CONNECTION
		fi;
	od;
}
proctype HostB()
{
	hostB_state = CLOSED; // hostB_state = SYN_RCVD; //MUTANT_08
	rcv_B = 0;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
			hostB_state = LISTEN; // hostB_state = ESTABLISHED_CONNECTION; //MUTANT_09
		::(hostB_state == LISTEN)->
			atomic
			{
				I_to_B?SYN,rcv_B;
				ack_B = rcv_B+1;//dont check value of ack because its the first ack sent
				printf("ack: %d\n",ack_B);
				printf("seq: %d\n",seq_B);
				B_to_A!ACK,ack_B;//sent ack back first 
				B_to_A!SYN,seq_B;//then send seq B for first time
				hostB_state = SYN_RCVD; // hostB_state = ESTABLISHED_CONNECTION; //MUTANT_10
			}
		::(hostB_state == SYN_RCVD)->		
			atomic
			{
				I_to_B?ACK,rcv_B;
				seq_B = rcv_B;
				hostB_state = ESTABLISHED_CONNECTION; // hostB_state = LAST_ACK; //MUTANT_11
			}
		::(hostB_state == ESTABLISHED_CONNECTION)->
			I_to_B?rcv_type_B,rcv_B;
			received = true;
			atomic
			{
				ack_B = rcv_B+1;
				printf("ack: %d\n",ack_B);
				B_to_A!ACK,ack_B;
				if
				::(rcv_type_B == FIN)-> //IMM_02
					hostB_state = CLOSE_WAIT; // hostB_state = CLOSED; //MUTANT_12
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
			hostB_state = LAST_ACK; // hostB_state = CLOSED; //MUTANT_13
		}
		::(hostB_state == LAST_ACK)->
			atomic
			{
				I_to_B?ACK, rcv_B;
				seq_B = rcv_B;
				hostB_state = CLOSED; // hostB_state = ESTABLISHED_CONNECTION; //MUTANT_14
				break;//to finish process
			}
		fi;
	od;
}

proctype Internet()
{
	do
	::
		if
		::(internet_state == CLOSED)->
			internet_state = LISTEN;
		::(internet_state == LISTEN)->
			A_to_I?rcv_type_I,rcv_I;
			if
			::(rcv_type_I == DATA)->//if message is of type data
				if
				::
					I_to_B!rcv_type_I,rcv_I;//transmit message to HostB
				::
					skip;//drop packet due to network congestion
				fi;
			::(rcv_type_I != DATA)->//if msg is not of type data
				I_to_B!rcv_type_I,rcv_I;// always transmit message to  HostB
				if
				::(rcv_type_I == FIN)->
					internet_state = CLOSING;
				::else->skip;
				fi;
			fi;
		::(internet_state == CLOSING)->
			A_to_I?rcv_type_I,rcv_I;
			assert(rcv_type_I==ACK);//IMM_01
			I_to_B!rcv_type_I,rcv_I;
			internet_state = CLOSED;
			break;
		fi;
	od;
}



init
{
	run HostA();
	run Internet();
	run HostB();
}


//control flow graph
//edge coverage
//node coverage
