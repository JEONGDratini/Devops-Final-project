'use strict'
const AWS = require('aws-sdk');

AWS.config.update({
    region: 'ap-northeast-2', 
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  });

//process.env.accessKeyId
const DynamoClient = new AWS.DynamoDB.DocumentClient();

//다이나모DB값 넣기
function recordLog(LogType, Logcontent) {
    console.log("Trying Dynamo")
    
    const item = {
      TableName: 'Dynamo_Log',
      Item: {
        Timestamp: new Date().toISOString(),
        LogType: LogType,
        Logcontent: Logcontent,
      },
    }

    return DynamoClient.put(item, (error, data) => {  
      if (error) {
        console.log("Error", error);
      } else {
        console.log("Success", data);
      }
    });
  }

module.exports = async function (fastify, opts) {
  //GET
  fastify.get('/', async function (request, reply) {

    const mysql = fastify.mysql;
      const query = `SELECT * FROM Task`;
      const result = await mysql.query(query);
      reply.code(200).send(result[0])

  })

  //POST
  fastify.post('/', async function (request, reply) {
    const Task_id = request.params.taskId;
    const { Task_name, Task_contents, Task_status, Deadline, PIC_email, Supervisor_email } = request.body;
    
    //log
    let LogType = 'create';
    let Logcontent = `Supervisor ${Supervisor_email} create Task ${Task_name} at ${new Date().toISOString()}`;
    console.log("Before Try Dynamo")
    try{
      await recordLog(LogType, Logcontent);
      console.log("After Try Dynamo")
    }catch(e){
      console.log(e);
      return {
        statusCode: 500,
        body: 'Error occurred'
      }
    }

    //mysql
    const mysql = fastify.mysql;
    const query = `INSERT INTO Task (Task_name, Task_contents, Task_status, Deadline, PIC_email, Supervisor_email) 
    VALUES ('${Task_name}','${Task_contents}','${Task_status}', '${Deadline}', '${PIC_email}', '${Supervisor_email}')`;
    
    const result = await mysql.query(query);
    //console.log(result);
    console.log("mysql completed");
    reply.code(200).send(result[0])

  });

 //PUT
  fastify.put('/:Task_id', async (request, reply) => {
    let Task_id = request.params.Task_id;
    const { Task_name, Task_contents, Task_status, Deadline, PIC_email, Supervisor_email } = request.body;
  
    //log
    let LogType = 'Update';
    let Logcontent = `Supervisor ${Supervisor_email} update Task ${Task_name} at ${new Date().toISOString()}`;
    
    //Done status
    if(Task_status == 'Done')
      LogType = 'Done';
      Logcontent = `Supervisor ${Supervisor_email} Done Task ${Task_name} at ${new Date().toISOString()}`;
    try{
      await recordLog(LogType, Logcontent);
    }catch(e){
      console.log(e);
      return {
        statusCode: 500,
        body: 'Error occurred'
      }
    }

    //mysql
    const mysql = fastify.mysql;
    const query = `UPDATE Task SET Task_name = '${Task_name}', 
    Task_contents = '${Task_contents}',
    Task_status = '${Task_status}',
    Deadline = '${Deadline}',
    PIC_email = '${PIC_email}',
    Supervisor_email = '${Supervisor_email}'
    WHERE Task_id = '${Task_id}'`;
    
    const result = await mysql.query(query);
    //console.log(result);
    console.log("mysql complete");
    reply.code(200).send(result[0])

  });

  //DELETE
  fastify.delete('/:Task_id', async (request, reply) => {
    let Task_id = request.params.Task_id;
    const { Task_name, Task_contents, Task_status, Deadline, PIC_email, Supervisor_email } = request.body;
    //log
    let LogType = 'Delete';
    let Logcontent = `Supervisor ${Supervisor_email} Delete Task ${Task_name} at ${new Date().toISOString()}`;
    try{
      await recordLog(LogType, Logcontent);
    }catch(e){
      console.log(e);
      return {
        statusCode: 500,
        body: 'Error occurred'
      }
    }

    //mysql
    const mysql = fastify.mysql;
    const query = `DELETE FROM Task WHERE Task_id = '${Task_id}'`;
    
    const result = await mysql.query(query);
    console.log(result);
    reply.code(200).send(result[0])
    
  });
}
