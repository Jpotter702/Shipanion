### ElevenLabs Client-Side Tools for Shipanion
1. get_shipping_quotes
This tool retrieves shipping quotes based on origin, destination, and package details.

Tool Definition:
{
  "name": "get_shipping_quotes",
  "description": "This tool retrieves shipping quotes based on origin, destination, and package details. When presenting shipping 
  
2. create_label
This tool creates a shipping label based on the selected shipping option.

Tool Definition:
3. track_package
This tool retrieves tracking information for a package.

Tool Definition:
Implementation Notes
Tool Names: The tool names used in our implementation are:

>- get_shipping_quotes
>- create_label
>- track_package

Session Continuity: We've configured the tools to carry session_id in the metadata:

Response Format: The tools expect responses in the format we've implemented in our WebSocket server, with both client_tool_result and contextual_update messages.

Example Usage: When registering these tools in the ElevenLabs dashboard, you can use the examples from our test scripts to demonstrate how they work.
When registering these tools in the ElevenLabs dashboard, make sure to use the exact same tool names and schemas as shown above to ensure compatibility with our implementation.