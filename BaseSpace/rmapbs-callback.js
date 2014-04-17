function launchSpec(dataProvider)
{
    var retval = {
        commandLine: ["python", "/home/methpipe/methpipe-wrapper/rmapbs-wrapper.py"],
        containerImageId:"songqiang/methpipe"
    };
	
    return retval;
}


// example multi-node launch spec
/*
function launchSpec(dataProvider)
{
    var retval = {
        nodes: []
    };
	
    retval.nodes.push({
        appSessionName: "Hello World 1",
        commandLine: ["/helloWorld.sh", "$AccessToken", "$AppSessionId", "$ApiUrl"],
        containerImageId:"tliu1/helloworld"
    });
	
    retval.nodes.push({
        appSessionName: "Hello World 2",
        commandLine: ["/helloWorld.sh", "$AccessToken", "$AppSessionId", "$ApiUrl"],
        containerImageId:"tliu1/helloworld"
    });
	
    return retval;
}
*/

/* 
function billingSpec(dataProvider) {
    return [
    {
        "Id" : "insert product ID here",
        "Quantity": 1.0
    }];
}
*/