function launchSpec(dataProvider)
{
    var methfile = dataProvider.GetProperty("Input.meth-file").Path;
	var iter = dataProvider.GetProperty("Input.num-iter");
	
    var retval = {
        commandLine: ["/home/methpipe/methpipe/bin/hmr", " -o t.bed ", " -i ", iter.toString(), " ", methfile, " -v "],
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