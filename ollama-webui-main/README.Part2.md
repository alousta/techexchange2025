Getting RAG to work in OpenWebUI with an Ollama backend is a straightforward process that involves setting up your environment, creating a knowledge base, and then using that knowledge to enhance your chat interactions.  Here's a simple step-by-step guide:

### **Initial Setup**

First, ensure you have **both Ollama and OpenWebUI installed and running**. That was completed in the first of this lab. To recap from part 1 - OpenWebUi and Ollama Installation:

* **Install Ollama:** If you don't have it yet, you'll need to install Ollama and pull at least one language model (like llama3:8b).  
* **Install OpenWebUI:** You can install it separately or use an image that includes both. For example, ghcr.io/open-webui/open-webui:ollama is a popular choice for an integrated setup.  
* **Verify Connection:** Make sure your OpenWebUI instance is successfully connected to the Ollama backend. You can usually check this in the Admin Panel settings, where you can verify the Ollama API address.

Watch the "Adding Ollama API Endpoint to OpenWebUI.mp4" video and follow up in your OpenWebUI installed application.
---

### **1\. Create a Knowledge Base**

A knowledge base is where you'll store all the documents you want your LLM to "know" about.

* On the left sidebar of the OpenWebUI interface, click **Workspace**.  
* Select the **Knowledge** tab at the top.  
* Click the **\+** button to create a new knowledge base.  
* Give it a descriptive **Name** and **Purpose**, then click "Create Knowledge". This will create an empty repository for your documents.

---

### **2\. Upload Documents**

Now, you'll add the content you want the model to use for Retrieval-Augmented Generation (RAG).

* Click on the new knowledge base you just created.  
* You will see an option to upload files. You can **drag and drop documents** (PDFs, text files, Markdown files, etc.) directly into the upload area.  
* Once uploaded, OpenWebUI automatically **parses the documents** and creates **embeddings** (vector representations) for them using an embedding model.

---

### **3\. Create a Custom Model (Optional)**

You can create a custom model that is pre-configured to use your knowledge base, making RAG even more seamless.

* In the **Workspace** section, navigate to the **Models** tab.  
* Click the **\+** button to add a new model.  
* Choose a **Base Model** from the ones you have available in Ollama.  
* Under **Knowledge Source**, select the knowledge base you created earlier.  
* Give your new RAG-enabled model a **Name** and then click "Save & Create". This doesn't create a new model, but rather a shortcut to use the base model with your specified knowledge base.

---

### **4\. Chat and Retrieve**

With everything set up, you can start asking questions.

* **Option 1: Use the Custom Model.** Start a new chat and select the custom model you created. Any query you make in this chat will automatically use your knowledge base for RAG.  
* **Option 2: Use a Document Manually.** In any chat, you can manually trigger RAG by typing a hashtag (\#) followed by the name of your knowledge base or document. A pop-up menu will appear, allowing you to select the source you want to use for the current query.  
* When the model responds, it will generate an answer based on its general knowledge, augmented by the specific information retrieved from your uploaded documents. OpenWebUI also provides **citations** to show which parts of the document were used to formulate the answer.