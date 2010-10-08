EDM Interface Engine
====================

A sinatra app that receives EDM notifications and retrieves the corresponding document.

Notification Subscriber Setup
-----------------------------

You can set the notification subscriber to post to the Sinatra app with this xml:

    <CfgInfo>
      <TargetPath>http://localhost:4567/transactions/new</TargetPath>
      <Username>admin</Username>
      <Password>admin</Password>
    </CfgInfo>

Example XPath for Pre Queue Cond:

    /NotifyData/Document/DocType[@DocTypeName="DCINST" or @DocTypeName="STM" or @DocTypeName="ER-TREAT" or @DocTypeName="DISCHARG"]

Example XPath for Post Queue Cond:

    //Owner[@OwnerTypeName="ENCOUNTER"]