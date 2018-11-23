pragma solidity ^0.4.0;

contract tictactoe {
    uint [3][3] final_board;
   // bool [3][3] locks;
    address [3][3] playeradd;
    //int startplayer=-1;
    int no_of_players;
    address last_played;
    address creator;
    //address owner=0;
    //address player0;
    //address player1;
    //bool flag1;
    //bool flag2;
    int no_of_moves=0;
    int winner;
    struct player{
        address add;
        //int choice;
        //bool flag;
        uint key;
        uint moves;
    }
    mapping(address => player) game;
    function tictactoe ()  public
    {
       /**/
        uint i;
        uint j;
        for (i=0;i<3;i++)
        {
            for (j=0;j<3;j++)
            {
                final_board[i][j]=0;
                //locks[i][j]=false;
                playeradd[i][j]=0;
            }
        }
        last_played=0;
        no_of_players=0;
        winner=-1;
        creator=msg.sender;
    }
    
    
    
    event Print2(string s1);
    
    function register() public returns (string)
    {
        
        if(game[msg.sender].add == msg.sender)
        {
            return ("You already registered");
        }
        if(no_of_players >= 2)
        {
            emit Print2("No more users allowed.");
            return ;
        }
        game[msg.sender].add = msg.sender;
        //game[msg.sender].flag=false;
        game[msg.sender].moves=0;
        if(no_of_players==0)
        {
            game[msg.sender].key=1;
            no_of_players++;
            return("successfully register and given 1 as key");
        }
        else
        {
            game[msg.sender].key=2;
            no_of_players++;
            return("successfully register and given 2 as key");
        }
        //no_of_players++;
       // return("successfully register");
       // return result;
    }

    
    event print(string s);
    function make_a_move(uint row, uint col) public returns(string){
        if(game[msg.sender].add==address(0))
        {
            return("You are not registered user");
        }
       // require(game[msg.sender].add!=address(0), "Not registered user");
        if(last_played==msg.sender)
        {
            return("You are not allowed to make a move now");
            
        }
        /*if(no_of_moves >0 && no_of_moves%2==0)
        {
            checkwinner();
        }*/
        if(final_board[row][col]!=0)
        {
            return ("Already marked,try another cell.");
            //return success;
        }
        if(final_board[row][col]==0)
        {
            final_board[row][col]=game[msg.sender].key;
            game[msg.sender].moves++;
            no_of_moves++;
            if(no_of_moves >0 && no_of_moves%2==0)
            {
                last_played=address(0);
            }
            else
            {
                last_played=msg.sender;
            }
            //success="Played successfully.";
            winner=checkwinner();
            if(winner==1)
            {
                display();
                emit print("Winner is : 1 :)");
                kill(creator);
                //return("Winner is : 1 :)");
                //return success;
            }
            else if(winner==2)
            {
                display();
                emit print("Winner is : 2 :)");
                kill(creator);
                //return("Winner is : 2 :)");
                //return success;
            }
            else if(no_of_moves >0 && no_of_moves%2==0)
                display();
            if(no_of_moves >= 9)
            {
                kill(creator);
            }
            return("Played Successfully)");
            
        }

    
    
}
    event Print(uint r1,uint r2,uint r3);
    event Print1(string s);
    function display() public
    {
        if((no_of_moves ==0 || no_of_moves %2==1) && winner==-1)
        {
           emit Print1("Not allowed to watch matrix.");
        }
        else
        {
            uint i;
            uint j;
            uint row1;
            uint row2;
            uint row3;
            for(i=0;i<3;i++)
            {
                j=0;
                if(i==0)
                {
                    row1=(final_board[i][j]*100)+(final_board[i][j+1]*10)+(final_board[i][j+2]);
                    row1=row1+3000;
                }
                if(i==1)
                {
                    row2=(final_board[i][j]*100)+(final_board[i][j+1]*10)+(final_board[i][j+2]);
                    row2=row2+3000;
                }
                if(i==2)
                {
                    row3=(final_board[i][j]*100)+(final_board[i][j+1]*10)+(final_board[i][j+2]);
                    row3=row3+3000;
                }
            }
            emit Print(row1,row2,row3);
        }
    }

    function checkwinner() private returns (int)
    {
        uint x=1;
        //int winner=-1;
        uint i;
        uint j;
        for(;x<3;x++)
        {
            for(i=0;i<3;i++)
            {
                j=0;
                //for(j=0;j<3;j++)
                
                    if(final_board[i][j]==x && final_board[i][j+1]==x && final_board[i][j+2]==x)
                    {
                        winner=int(x);
                        break;
                    }
                    else if(final_board[j][i]==x && final_board[j+1][i]==x && final_board[j+2][i]==x )
                    {
                        winner=int(x);
                        break;
                    }
                    else if(final_board[0][0]==x && final_board[1][1]==x && final_board[2][2]==x || final_board[0][2]==x && final_board[1][1]==x && final_board[2][0]==x)
                    {
                        winner=int(x);
                        break;
                    }
            }
            if(winner!=-1)
            {
                return winner;
            }
        }
        return winner;
    }
    function kill(address callerr) private
    {
        
        selfdestruct(callerr);
        
    }
}