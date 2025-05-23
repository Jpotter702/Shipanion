# Widget customization

> Learn how to customize the widget appearance to match your brand, and personalize the agent's behavior from html.

**Widgets** enable instant integration of Conversational AI into any website. You can either customize your widget through the UI or through our type-safe [Conversational AI SDKs](/docs/conversational-ai/libraries) for complete control over styling and behavior. The SDK overrides take priority over UI customization.

<Note>
  Widgets currently require public agents with authentication disabled. Ensure this is disabled in
  the **Advanced** tab of your agent settings.
</Note>

## Embedding the widget

Add this code snippet to your website's `<body>` section. Place it in your main `index.html` file for site-wide availability:

<CodeBlocks>
  ```html title="Widget embed code"
  <elevenlabs-convai agent-id="<replace-with-your-agent-id>"></elevenlabs-convai>
  <script src="https://elevenlabs.io/convai-widget/index.js" async type="text/javascript"></script>
  ```
</CodeBlocks>

<Info>
  For enhanced security, define allowed domains in your agent's **Allowlist** (located in the
  **Security** tab). This restricts access to specified hosts only.
</Info>

## Widget attributes

This basic embed code will display the widget with the default configuration defined in the agent's dashboard.
The widget supports various HTML attributes for further customization:

<AccordionGroup>
  <Accordion title="Core configuration">
    ```html
    <elevenlabs-convai
      agent-id="agent_id"              // Required: Your agent ID
      signed-url="signed_url"          // Alternative to agent-id
      server-location="us"             // Optional: "us" or default
      variant="expanded"               // Optional: Widget display mode
    ></elevenlabs-convai>
    ```
  </Accordion>

  <Accordion title="Visual customization">
    ```html
    <elevenlabs-convai
      avatar-image-url="https://..." // Optional: Custom avatar image
      avatar-orb-color-1="#6DB035" // Optional: Orb gradient color 1
      avatar-orb-color-2="#F5CABB" // Optional: Orb gradient color 2
    ></elevenlabs-convai>
    ```
  </Accordion>

  <Accordion title="Text customization">
    ```html
    <elevenlabs-convai
      action-text="Need assistance?"         // Optional: CTA button text
      start-call-text="Begin conversation"   // Optional: Start call button
      end-call-text="End call"              // Optional: End call button
      expand-text="Open chat"               // Optional: Expand widget text
      listening-text="Listening..."         // Optional: Listening state
      speaking-text="Assistant speaking"     // Optional: Speaking state
    ></elevenlabs-convai>
    ```
  </Accordion>
</AccordionGroup>

## Runtime configuration

Two more html attributes can be used to customize the agent's behavior at runtime. These two features can be used together, separately, or not at all

### Dynamic variables

Dynamic variables allow you to inject runtime values into your agent's messages, system prompts, and tools.

```html
<elevenlabs-convai
  agent-id="your-agent-id"
  dynamic-variables='{"user_name": "John", "account_type": "premium"}'
></elevenlabs-convai>
```

All dynamic variables that the agent requires must be passed in the widget.

<Info>
  See more in our [dynamic variables
  guide](/docs/conversational-ai/customization/personalization/dynamic-variables).
</Info>

### Overrides

Overrides enable complete customization of your agent's behavior at runtime:

```html
<elevenlabs-convai
  agent-id="your-agent-id"
  override-language="es"
  override-prompt="Custom system prompt for this user"
  override-first-message="Hi! How can I help you today?"
  override-voice-id="axXgspJ2msm3clMCkdW3"
></elevenlabs-convai>
```

Overrides can be enabled for specific fields, and are entirely optional.

<Info>
  See more in our [overrides
  guide](/docs/conversational-ai/customization/personalization/overrides).
</Info>

## Visual customization

Customize the widget's appearance, text content, language selection, and more in the [dashboard](https://elevenlabs.io/app/conversational-ai/dashboard) **Widget** tab.

<Frame background="subtle">
  ![Widget customization](file:322aeb66-b1d2-4132-ada3-41f2dbfbb3d1)
</Frame>

<Tabs>
  <Tab title="Appearance">
    Customize the widget colors and shapes to match your brand identity.

    <Frame background="subtle">
      ![Widget appearance](file:a7629f4f-aade-43c4-b7c5-15dd7dbc4d24)
    </Frame>
  </Tab>

  <Tab title="Feedback">
    Gather user insights to improve agent performance. This can be used to fine-tune your agent's knowledge-base & system prompt.

    <Frame background="subtle">
      ![Widget feedback](file:f6a7ae62-c6ad-4120-99e7-ed7a584c9bb2)
    </Frame>

    **Collection modes**

    * <strong>None</strong>: Disable feedback collection entirely.
    * <strong>During conversation</strong>: Support real-time feedback during conversations. Additionnal metadata such as the agent response that prompted the feedback will be collected to help further identify gaps.
    * <strong>After conversation</strong>: Display a single feedback prompt after the conversation.

    <Note>
      Send feedback programmatically via the [API](/docs/conversational-ai/api-reference/conversations/post-conversation-feedback) when using custom SDK implementations.
    </Note>
  </Tab>

  <Tab title="Avatar">
    Configure the voice orb or provide your own avatar.

    <Frame background="subtle">
      ![Widget orb customization](file:88792f2a-336e-428e-97ff-26604fde6bf7)
    </Frame>

    **Available options**

    * <strong>Orb</strong>: Choose two gradient colors (e.g., #6DB035 & #F5CABB).
    * <strong>Link/image</strong>: Use a custom avatar image.
  </Tab>

  <Tab title="Display text">
    Customize all displayed widget text elements, for example to modify button labels.

    <Frame background="subtle">
      ![Widget text contents](file:a576bec6-1785-4818-8210-8ee5da645408)
    </Frame>
  </Tab>

  <Tab title="Terms">
    Display custom terms and conditions before the conversation.

    <Frame background="subtle">
      ![Terms setup](file:5170df49-efc3-45a7-9245-ce05c0782092)
    </Frame>

    **Available options**

    * <strong>Terms content</strong>: Use Markdown to format your policy text.
    * <strong>Local storage key</strong>: A key (e.g., "terms\_accepted") to avoid prompting returning users.

    **Usage**

    The terms are displayed to users in a modal before starting the call:

    <Frame background="subtle">
      ![Terms display](file:25562642-8be7-4b6d-993f-29c16b69bfb6)
    </Frame>

    The terms can be written in Markdown, allowing you to:

    * Add links to external policies
    * Format text with headers and lists
    * Include emphasis and styling

    For more help with Markdown, see the [CommonMark help guide](https://commonmark.org/help/).

    <Info>
      Once accepted, the status is stored locally and the user won't be prompted again on subsequent
      visits.
    </Info>
  </Tab>

  <Tab title="Language">
    Enable multi-language support in the widget.

    ![Widget language](file:39833b98-8bcf-4b9f-a3d3-7a63d6c26957)

    <Note>
      To enable language selection, you must first [add additional
      languages](/docs/conversational-ai/customization/language) to your agent.
    </Note>
  </Tab>

  <Tab title="Muting">
    Allow users to mute their audio in the widget.

    ![Widget's mute button](file:afe79bef-c5b8-495f-946d-6e1fa979fe46)

    To add the mute button please enable this in the `interface` card of the agent's `widget`
    settings.

    ![Widget's mute button](file:9786e224-a1cb-4e47-a260-376429003a7f)
  </Tab>

  <Tab title="Shareable page">
    Customize your public widget landing page (shareable link).

    <Frame background="subtle">
      ![Widget shareable page](file:8b3b34b9-a990-4367-b1dc-45e3f77d64aa)
    </Frame>

    **Available options**

    * <strong>Description</strong>: Provide a short paragraph explaining the purpose of the call.
  </Tab>
</Tabs>

***

## Advanced implementation

<Note>
  For more advanced customization, you should use the type-safe [Conversational AI
  SDKs](/docs/conversational-ai/libraries) with a Next.js, React, or Python application.
</Note>

### Client Tools

Client tools allow you to extend the functionality of the widget by adding event listeners. This enables the widget to perform actions such as:

* Redirecting the user to a specific page
* Sending an email to your support team
* Redirecting the user to an external URL

To see examples of these tools in action, start a call with the agent in the bottom right corner of this page. The [source code is available on GitHub](https://github.com/elevenlabs/elevenlabs-docs/blob/main/fern/assets/scripts/widget.js) for reference.

#### Creating a Client Tool

To create your first client tool, follow the [client tools guide](/docs/conversational-ai/customization/tools/client-tools).

<Accordion title="Example: Creating the `redirectToExternalURL` Tool">
  <Frame background="subtle">
    ![Client tool configuration](file:281ae5e8-14f6-4621-b2c1-2b33742a19d6)
  </Frame>
</Accordion>

#### Example Implementation

Below is an example of how to handle the `redirectToExternalURL` tool triggered by the widget in your JavaScript code:

<CodeBlocks>
  ```javascript title="index.js"
  document.addEventListener('DOMContentLoaded', () => {
    const widget = document.querySelector('elevenlabs-convai');

    if (widget) {
      // Listen for the widget's "call" event to trigger client-side tools
      widget.addEventListener('elevenlabs-convai:call', (event) => {
        event.detail.config.clientTools = {
          // Note: To use this example, the client tool called "redirectToExternalURL" (case-sensitive) must have been created with the configuration defined above.
          redirectToExternalURL: ({ url }) => {
            window.open(url, '_blank', 'noopener,noreferrer');
          },
        };
      });
    }
  });
  ```
</CodeBlocks>

<Info>
  Explore our type-safe [SDKs](/docs/conversational-ai/libraries) for React, Next.js, and Python
  implementations.
</Info>
Highlight connections
0 connections found
Actions
