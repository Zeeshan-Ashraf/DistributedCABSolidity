pragma solidity ^0.4.0;
contract cab 
{
    string public printFrom;
    string public printTo;
    uint256 public printSeq;
    
    address cab_service_provider;
    uint256 account_no;
    uint256 security_deposit;
    uint256 cnt;
    
    event Print(string from, string to,string temp1,string temp2,string temp3, uint256 seq);
    
    struct UserAccount 
    {
        int IsCabDriver;
        int cabAssigned;
        uint256 balance;
        address UserAdd;
        address DriverAdd;
        string from;
        string to;
        uint256 seq;
    }
    
    struct auction_data 
    {
        uint256 seq;
        string to;
        string from;
        uint256 betAmt;
        uint256 auctionDeadline;
        address lowestDriver;
        address PassengerAdd;
    }
    
    mapping(uint256 => UserAccount) account;
    mapping(uint256 => auction_data) requests;
    
    function cab(uint256 SecDepo) public
    {
        cab_service_provider = msg.sender;
        account_no = 0;
        cnt = 1;
        security_deposit = SecDepo;
    }
    
    function CabRegister(uint256 bal) public returns(string,uint256)
    {
        if (msg.sender==cab_service_provider)
        {
            return ("Can't register, This is address of cab_service_provider smart contract: ",0);
        }
        if(bal<security_deposit)
        {
            return ("Min Balance required to register: ",security_deposit);
        }
        
        for(uint256 i=0;i<account_no;i++)
        {
            if(account[i].UserAdd==msg.sender || account[i].DriverAdd==msg.sender)
            {
                return ("Already registered : ",i);
            }
        }
        
        account[account_no].IsCabDriver=1;
        account[account_no].balance=bal;
        account[account_no].cabAssigned=0;
        account[account_no].DriverAdd=msg.sender;
        account[account_no].UserAdd=0;
        account[account_no].from="0";
        account[account_no].to="0";
        account[account_no].seq=0;
        
        account_no++;
        return ("Your Account no is: ",account_no-1);
    }
    
    function PassengerRegister(uint256 bal) public returns(string,uint256)
    {
        if (msg.sender==cab_service_provider)
        {
            return ("Can not register, This is address of cab_service_provider smart contract: ",0);
        }
        if(bal<security_deposit)
        {
            return ("Min Balance required to register is: ",security_deposit);
        }
        
        for(uint256 i=0;i<account_no;i++)
        {
            if(account[i].UserAdd==msg.sender || account[i].DriverAdd==msg.sender)
            {
                return ("Already registered : ",i);
            }
        }
        
        account[account_no].IsCabDriver=0;
        account[account_no].balance=bal;
        account[account_no].cabAssigned=0;
        account[account_no].UserAdd=msg.sender;
        account[account_no].DriverAdd=0;
        account[account_no].from="0";
        account[account_no].to="0";
        account[account_no].seq=0;
        
        account_no++;
        return ("Your Account no is: ",account_no-1);
    }
    
    function RequestCab(string fromm, string too) public returns(string,uint256,string,string,string)
    {
        uint256 i;
        if (msg.sender==cab_service_provider)
        {
            return ("Can not Request, This is address of cab_service_provider smart contract: ",0,"-","-","-");
        }
        
        for(i=0;i<account_no;i++)
            if(account[i].UserAdd==msg.sender || account[i].DriverAdd==msg.sender)
                break;
        if(i==account_no)
            return ("Not a registered user, plz register first: ",0,"-","-","-");
        
        if(account[i].balance<security_deposit)
        {
            return ("Not enough Balance to proceed, min required:",security_deposit,"-","-","-");
        }
        
        if(account[i].cabAssigned!=0)
            return ("You already have assigned a cab,wait for journey to finish: ",i,"-","-","-");
        
        if(keccak256(account[i].from)!=keccak256("0"))
            return ("You already requested a cab,wait for cab to be assigned: ",i,"-","-","-");
        
        account[i].from=fromm;
        account[i].to=too;
        account[i].seq=cnt;
        cnt++;
        
        requests[account[i].seq].from=fromm;
        requests[account[i].seq].to=too;
        requests[account[i].seq].betAmt=100000;
        requests[account[i].seq].auctionDeadline=now+600;
        requests[account[i].seq].lowestDriver=0;
        requests[account[i].seq].PassengerAdd=msg.sender;
        
        return ("Request in Queue for cab from: ",0,account[i].from," to: ",account[i].to);
    }
    
    function showAllReq() public returns(string)
    {
        for(uint256 i=0;i<account_no;i++)
        {
            if(keccak256(account[i].from)!=keccak256("0"))
            {
                //log0(bytes32(account[i].seq));
                printing(account[i].from,account[i].to,account[i].seq);
            }
        }
        return ("check list of seq in log");
    }
    
    function printing(string fromm, string too, uint256 seqqq) public
    {
      printFrom = fromm;
      printTo = too;
      printSeq=seqqq;
      Print("From:",printFrom,"To",printTo,"SeqNo:",printSeq);
    }
    
    
    function ResponseBetOnRequests(uint256 seqq,uint256 betAmtt) public returns(string,uint256)
    {
        if(msg.sender==requests[seqq].PassengerAdd)
            return ("you can not response on your own request",0);
        
        if(requests[seqq].betAmt>betAmtt)
        {
            requests[seqq].betAmt=betAmtt;
            requests[seqq].lowestDriver=msg.sender;
        }
        return ("Auction applied, wait for result",requests[seqq].betAmt);
    }
    
    function cabAssignment() public returns(string,uint256)
    {
        for(uint256 i=0;i<account_no;i++)
        {
            if(keccak256(account[i].from)!=keccak256("0"))
            {
                if(requests[account[i].seq].auctionDeadline<now+700)
                {
                    if(requests[account[i].seq].betAmt==100000)
                        return ("Sorry No Driver auctioned, try again",0);
                    else if(requests[account[i].seq].betAmt > account[i].balance)
                        return ("Auctioned amount is more than your balance, plz update balance",0);
                    else
                    {
                        account[i].from = "0";
                        account[i].to = "0";
                        account[i].balance = account[i].balance-requests[account[i].seq].betAmt;
                        delete requests[account[i].seq];
                        account[i].seq=0;
                        
                        return ("Request is served for user",0);
                    }
                }
            }
        }
        
        return ("Auction applied, wait for result",0);
    }
    
    function CancelRequestedCabByUser() public returns(string,uint256,string,string,string)
    {
        uint256 i;
        if (msg.sender==cab_service_provider)
        {
            return ("Can not cancel, This is address of cab_service_provider smart contract: ",0,"-","-","-");
        }
        
        for(i=0;i<account_no;i++)
            if(account[i].UserAdd==msg.sender)
                break;
        if(i==account_no)
            return ("Not a registered user, plz register first: ",i,"-","-","-");
        
        if(account[i].cabAssigned!=0)
            return ("You are riding cab,can not cancel now: ",i,"-","-","-");
        
        
        if(account[i].seq==0)
            return ("No request found to cancel: ",i,"-","-","-");
        else
        {
            string frmm=requests[account[i+1].seq].from;
            string tooo=requests[account[i+1].seq].to;
            delete requests[account[i+1].seq];
            account[i+1].from = "0";
            account[i+1].to = "0";
            account[i+1].seq==0;
            account[i+1].balance=account[i+1].balance-5;
            return ("Your ride request cancelled: ",i+1,"From-to",frmm,tooo);
        }
            
        
        return ("done: ",0,"-","-","-");
    }
    
    function CancelAssignedCabByDriver() public returns(string,uint256,string,string,string)
    {
        uint256 i;
        if (msg.sender==cab_service_provider)
        {
            return ("Can not cancel, This is address of cab_service_provider smart contract: ",0,"-","-","-");
        }
        
        for(i=0;i<account_no;i++)
            if(account[i].DriverAdd==msg.sender)
                break;
        if(i==account_no)
            return ("Not a registered Driver, plz register first: ",i,"-","-","-");
        
        account[i+1].balance=account[i+1].balance-5;
        return ("Your cancell request applied & charged 5/-: ",i+1,"-","frmm","tooo");
            
    }
    
}