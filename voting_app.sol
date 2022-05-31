// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IVotingContract{
 enum Phase  {
        Registration,
        Voting,
        Results
                }

//only one address should be able to add candidates
    function addCandidate(address _candidate, string memory _name) external returns(bool);

    // SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IVotingContract{
 enum Phase  {
        Registration,
        Voting,
        Results
                }

//only one address should be able to add candidates
    function addCandidate(address _candidate, string memory _name) external returns(bool);

    
    function voteCandidate(address candidateId) external returns(bool);

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() external returns(string memory _winnerName);


}



contract VotingContract is IVotingContract {

     struct Voter {
        address voterId;
        bool voted;
        address IdOfCandidateVotedFor;
    }

    struct Candidate {
        address candidateId;
        string name;
        uint publicVoteCount;
    }

    address public chairperson;
    uint public genesisTime;
    uint constant PHASE_DURATION = 3 minutes;
    Candidate[] public candidateList;
    Phase public votingPhase;
    mapping(address => Voter) public voters;

    constructor () {
        chairperson = msg.sender;
        genesisTime = block.timestamp;
    }


        /*Prevents actions from occuring any phase other than what is specified */
        modifier atPhase(Phase _phase) {
        require(votingPhase == _phase, ("Cannot perform action at this phase"));
        //require(votingPhase == _phase, )
        _;
    }
     function nextPhase() internal {
        votingPhase = Phase(uint(votingPhase) + 1);
       //votingPhase = Phase.Results;


    }
    /* Modifier that conditionally calls the next phase function before functions it's applied to,
     so that atPhase() can validate accordingly */
    modifier timedTransitions(Phase _votingPhase) {
        if (_votingPhase == Phase.Registration && block.timestamp >= genesisTime + PHASE_DURATION) {
            nextPhase();
        }
          if (_votingPhase == Phase.Voting && block.timestamp >= genesisTime + PHASE_DURATION && block.timestamp >= genesisTime + (PHASE_DURATION * 2) ){
            nextPhase();
        }
        _;
    }
       /*  modifier transitionAfter() {
        _;
        nextPhase();
    } */

    /* Checks if address is eligible to vote */
    function canVote (address _voterId) private view returns (bool hasVotingRight){
        if (voters[_voterId].voterId == _voterId && _voterId != address(0) && msg.sender != chairperson){
            return true;
        }

        return false;
    }


    function getCandidiates() public view returns (Candidate[] memory candidates){
        return candidateList;
    }
    /* Helper to check if candidate is unique */
    function uniqueCandidate(address _candidateId) private view returns(bool){
        bool isUnique = true;
        for(uint i = 0; i < candidateList.length; i++){
            if(candidateList[i].candidateId == _candidateId ){
                isUnique = false;
            }
        }
        return isUnique;
    }
    /* Helper to check if candidate exists */
    function isExistingCandidate(address _candidateId) private view returns (bool){
        bool isExisting = false;
        for(uint i = 0; i < candidateList.length; i++){
             if(candidateList[i].candidateId == _candidateId ){
                isExisting = true;
            }
        }

        return isExisting;
    }


/* Gets the current phase for testing */
    function getPhase() public view returns (string memory state){
        if (block.timestamp <= genesisTime + PHASE_DURATION ){
            return "Registration";
        }
        if (block.timestamp >= genesisTime + PHASE_DURATION && block.timestamp <= genesisTime + (PHASE_DURATION * 2) ){
            return "Voting";
        }
       return "Results";

    }

/* This adds a candidate within the alloted time and phase*/

    function addCandidate(address _candidateId, string memory _name) external override timedTransitions(votingPhase) atPhase(Phase.Registration) returns(bool){
        // require (block.timestamp <= genesisTime + THREE_MINUTES );
        require(uniqueCandidate(_candidateId), "Candidate already exists");
        candidateList.push(Candidate({candidateId: _candidateId, publicVoteCount: 0, name: _name }));
        return true;


    }

/* Gets a candidate's index by address */
    function getCandidateIndexByAddress (address _candidateId) view public returns(uint index){
     for(uint i = 0; i < candidateList.length; i++){
         if (candidateList[i].candidateId == _candidateId){
             return i;
         }

    }

    }
    /* Allows any given address to vote if conditions are met*/

    function voteCandidate(address _candidateId) external override timedTransitions(votingPhase) atPhase(Phase.Voting) returns(bool success){
        require(canVote(msg.sender), "You are not eligible to vote");
        require(voters[msg.sender].voted == false, "You cannot vote more than once.");
        require(isExistingCandidate(_candidateId), "Candidate does not exist");
        require(candidateList.length >= 1);          
        uint candidateIndex = getCandidateIndexByAddress(_candidateId);
        candidateList[candidateIndex].publicVoteCount += 1;
        voters[msg.sender].voted = true;
        voters[msg.sender].IdOfCandidateVotedFor = _candidateId;

        
        return true;
        


    }

    /*Returns the index of the winning candidate, so that getWinner can extract the name. */

    function getWinningCandidate() private view returns (uint winningCandidate_){
          
        uint winningVoteCount = 0;
        if (candidateList.length > 1){
        for (uint p = 0; p < candidateList.length; p++) {
            if (candidateList[p].publicVoteCount > winningVoteCount) {
                winningVoteCount = candidateList[p].publicVoteCount;
                winningCandidate_ = p;
            }
        }
        }
        else {
            winningCandidate_ = 0; //Unanimous victory
        }


    }

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() timedTransitions(votingPhase) atPhase(Phase.Results)  external override returns(string memory winnerName_){
        //require(msg.sender == chairperson, "Only Chairperson can see the winner.");
        
        winnerName_ = candidateList[getWinningCandidate()].name;
      

        return winnerName_;

    }

}
    function voteCandidate(address candidateId) external returns(bool);

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() external returns(string memory _winnerName);


}



contract VotingContract is IVotingContract {

     struct Voter {
        address voterId;
        bool voted;
        address IdOfCandidateVotedFor;
    }

    struct Candidate {
        address candidateId;
        string name;
        uint publicVoteCount;
    }

    address public chairperson;
    uint public genesisTime;
    uint constant PHASE_DURATION = 1 minutes;
    Candidate[] public candidateList;
    Phase public votingPhase;
    mapping(address => Voter) public voters;

    constructor () {
        chairperson = msg.sender;
        genesisTime = block.timestamp;
    }



        modifier atPhase(Phase _phase) {
        require(votingPhase == _phase, ("Cannot perform action at this phase"));
        _;
    }
     function nextPhase() internal {
        votingPhase = Phase(uint(votingPhase) + 1);
       //votingPhase = Phase.Results;


    }

    modifier timedTransitions(Phase _votingPhase) {
        if (_votingPhase == Phase.Registration && block.timestamp >= genesisTime + PHASE_DURATION) {
            nextPhase();
        }
        if (_votingPhase == Phase.Voting && block.timestamp >= genesisTime + PHASE_DURATION) {
            nextPhase();
        }
        _;
    }
        modifier transitionAfter() {
        _;
        nextPhase();
    }


    function canVote (address _voterId) private view returns (bool hasVotingRight){
        if (voters[_voterId].voterId == _voterId && _voterId != address(0)){
            return true;
        }

        return false;
    }


    function getCandidiates() public view returns (Candidate[] memory candidates){
        return candidateList;
    }

    function uniqueCandidate(address _candidateId) private view returns(bool){
        bool isUnique = true;
        for(uint i = 0; i < candidateList.length; i++){
            if(candidateList[i].candidateId == _candidateId ){
                isUnique = false;
            }
        }
        return isUnique;
    }

    function isExistingCandidate(address _candidateId) private view returns (bool){
        bool isExisting = false;
        for(uint i = 0; i < candidateList.length; i++){
             if(candidateList[i].candidateId == _candidateId ){
                isExisting = true;
            }
        }

        return isExisting;
    }



    function getPhase() public view returns (string memory state){
        if (block.timestamp <= genesisTime + PHASE_DURATION ){
            return "Registration";
        }
        if (block.timestamp <= genesisTime + PHASE_DURATION * 2){
            return "Voting";
        }
       return "Results";

    }



    function addCandidate(address _candidateId, string memory _name) external override timedTransitions(votingPhase) atPhase(Phase.Registration) returns(bool){
        // require (block.timestamp <= genesisTime + THREE_MINUTES );
        require(uniqueCandidate(_candidateId), "Candidate already exists");
        candidateList.push(Candidate({candidateId: _candidateId, publicVoteCount: 0, name: _name }));
        return true;


    }

    function getCandidateIndexByAddress (address _candidateId) view public returns(uint index){
     for(uint i = 0; i < candidateList.length; i++){
         if (candidateList[i].candidateId == _candidateId){
             return i;
         }

    }

    }

    function voteCandidate(address _candidateId) external override timedTransitions(votingPhase) atPhase(Phase.Voting) returns(bool success){
        //require(canVote(msg.sender), "You are not eligible to vote");
        require(isExistingCandidate(_candidateId), "Candidate does not exist");
        uint candidateIndex = getCandidateIndexByAddress(_candidateId);
        candidateList[candidateIndex].publicVoteCount += 1;
        voters[msg.sender].voted = true;
        voters[msg.sender].IdOfCandidateVotedFor = _candidateId;

        


        return true;
        


    }

    function getWinningCandidate() private view returns (uint winningCandidate_){
          
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidateList.length; p++) {
            if (candidateList[p].publicVoteCount > winningVoteCount) {
                winningVoteCount = candidateList[p].publicVoteCount;
                winningCandidate_ = p;
            }
        }


    }

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() timedTransitions(votingPhase) atPhase(Phase.Results)  external override returns(string memory winnerName_){
        
        winnerName_ = candidateList[getWinningCandidate()].name;
      

    }
}// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IVotingContract{
 enum Phase  {
        Registration,
        Voting,
        Results
                }

//only one address should be able to add candidates
    function addCandidate(address _candidate, string memory _name) external returns(bool);

    
    function voteCandidate(address candidateId) external returns(bool);

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() external returns(string memory _winnerName);


}



contract VotingContract is IVotingContract {

     struct Voter {
        address voterId;
        bool voted;
        address IdOfCandidateVotedFor;
    }

    struct Candidate {
        address candidateId;
        string name;
        uint publicVoteCount;
    }

    address public chairperson;
    uint public genesisTime;
    uint constant PHASE_DURATION = 1 minutes;
    Candidate[] public candidateList;
    Phase public votingPhase;
    mapping(address => Voter) public voters;

    constructor () {
        chairperson = msg.sender;
        genesisTime = block.timestamp;
    }



        modifier atPhase(Phase _phase) {
        require(votingPhase == _phase, ("Cannot perform action at this phase"));
        _;
    }
     function nextPhase() internal {
        votingPhase = Phase(uint(votingPhase) + 1);
       //votingPhase = Phase.Results;


    }

    modifier timedTransitions(Phase _votingPhase) {
        if (_votingPhase == Phase.Registration && block.timestamp >= genesisTime + PHASE_DURATION) {
            nextPhase();
        }
        if (_votingPhase == Phase.Voting && block.timestamp >= genesisTime + PHASE_DURATION) {
            nextPhase();
        }
        _;
    }
        modifier transitionAfter() {
        _;
        nextPhase();
    }


    function canVote (address _voterId) private view returns (bool hasVotingRight){
        if (voters[_voterId].voterId == _voterId && _voterId != address(0)){
            return true;
        }

        return false;
    }


    function getCandidiates() public view returns (Candidate[] memory candidates){
        return candidateList;
    }

    function uniqueCandidate(address _candidateId) private view returns(bool){
        bool isUnique = true;
        for(uint i = 0; i < candidateList.length; i++){
            if(candidateList[i].candidateId == _candidateId ){
                isUnique = false;
            }
        }
        return isUnique;
    }

    function isExistingCandidate(address _candidateId) private view returns (bool){
        bool isExisting = false;
        for(uint i = 0; i < candidateList.length; i++){
             if(candidateList[i].candidateId == _candidateId ){
                isExisting = true;
            }
        }

        return isExisting;
    }



    function getPhase() public view returns (string memory state){
        if (block.timestamp <= genesisTime + PHASE_DURATION ){
            return "Registration";
        }
        if (block.timestamp <= genesisTime + PHASE_DURATION * 2){
            return "Voting";
        }
       return "Results";

    }



    function addCandidate(address _candidateId, string memory _name) external override timedTransitions(votingPhase) atPhase(Phase.Registration) returns(bool){
        // require (block.timestamp <= genesisTime + THREE_MINUTES );
        require(uniqueCandidate(_candidateId), "Candidate already exists");
        candidateList.push(Candidate({candidateId: _candidateId, publicVoteCount: 0, name: _name }));
        return true;


    }

    function getCandidateIndexByAddress (address _candidateId) view public returns(uint index){
     for(uint i = 0; i < candidateList.length; i++){
         if (candidateList[i].candidateId == _candidateId){
             return i;
         }

    }

    }

    function voteCandidate(address _candidateId) external override timedTransitions(votingPhase) atPhase(Phase.Voting) returns(bool success){
        //require(canVote(msg.sender), "You are not eligible to vote");
        require(isExistingCandidate(_candidateId), "Candidate does not exist");
        uint candidateIndex = getCandidateIndexByAddress(_candidateId);
        candidateList[candidateIndex].publicVoteCount += 1;
        voters[msg.sender].voted = true;
        voters[msg.sender].IdOfCandidateVotedFor = _candidateId;

        


        return true;
        


    }

    function getWinningCandidate() private view returns (uint winningCandidate_){
          
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidateList.length; p++) {
            if (candidateList[p].publicVoteCount > winningVoteCount) {
                winningVoteCount = candidateList[p].publicVoteCount;
                winningCandidate_ = p;
            }
        }


    }

    //getWinner returns the name of the winner (address with most votes)
    function getWinner() timedTransitions(votingPhase) atPhase(Phase.Results)  external override returns(string memory winnerName_){
        
        winnerName_ = candidateList[getWinningCandidate()].name;
      

    }
}