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

/*Roles*/
#define CLIENT 0
#define SERVER 1

/*Message Types*/
mtype = {Seq, Ack, Establishing, Established}

/*Channels*/
chan hostA_internet = [1] of {mtype, int};
chan hostB_internet = [1] of {mtype, int};

/*States of Processes*/
byte hostA_state = CLOSED;
byte hostB_state = CLOSED;

/*Role of Processes*/
byte hostA_role;
byte hostB_role;

/*Storage for received messages*/
int hostA_msg;
int hostB_msg;
int internet_msg;


int Timer_A = 0;
int x = 0;
int y = 0;

proctype HostA()
{
	byte hostA_state = CLOSED;
	hostA_msg =0;
	hostA_role = CLIENT;
	do
	::
		if
		::(hostA_state == CLOSED)->
		::(hostA_state == LISTEN)->
		::(hostA_state == SYN_RCVD)->
		::(hostA_state == SYN_SENT)->
		::(hostA_state == ESTABLISHED_CONNECTION)->
		::(hostA_state == FIN_WAIT_1)->
		::(hostA_state == FIN_WAIT_2)->
		::(hostA_state == TIMED_WAIT)->
		::(hostA_state == CLOSING)->
		::(hostA_state == CLOSE_WAIT)->
		::(hostA_state == LAST_ACK)->
		fi;
	od;

	
	
	SEVER_STATE!Establishing;
	
	x++;
	SYN!Seq, x;
	SYN?Seq, y;
	SYN?Ack, x;
	SYN!Seq, x++;
	SYN!Ack, y++;
	
	SERVER_STATE?state;
	
	if
	:: (state == Established) ->
	
	fi;
	
}

proctype HostB()
{
	byte hostB_state = CLOSED;
	hostB_msg = 0;
	hostB_role = SERVER;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
		::(hostB_state == LISTEN)->
		::(hostB_state == SYN_RCVD)->
		::(hostB_state == SYN_SENT)->
		::(hostB_state == ESTABLISHED_CONNECTION)->
		::(hostB_state == FIN_WAIT_1)->
		::(hostB_state == FIN_WAIT_2)->
		::(hostB_state == TIMED_WAIT)->
		::(hostB_state == CLOSING)->
		::(hostB_state == CLOSE_WAIT)->
		::(hostB_state == LAST_ACK)->
		fi;
	od;
	
	
	
	SYN?Seq, x ;
	SYN!Seq, y;
	SYN!Ack, x++;
	SYN?Seq, x;
	SYN?Ack, y;
	
	SEVER_STATE!Established;
	
	
}

proctype Internet()
{




}


init
{
	run HostA();
	run HostB();

}