import 'package:flutter/material.dart';
import 'package:nillion_chat/service/nillion_api_service.dart';
import 'package:nillion_chat/service/utils/colors.dart';
import 'package:nillion_chat/service/utils/images.dart';
import 'package:nillion_chat/service/utils/prompt_constants.dart';

class NillionThreadAppView extends StatefulWidget {
  const NillionThreadAppView({super.key});

  @override
  _NillionThreadAppViewState createState() => _NillionThreadAppViewState();
}

class _NillionThreadAppViewState extends State<NillionThreadAppView> {
  final _threadController = TextEditingController();

  final List<TextEditingController> _referenceControllers = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _addReferenceField();
  }

  bool isLoading = false;
  void uploadLoading({bool status = false}) {
    setState(() {
      isLoading = status;
    });
  }

  @override
  void dispose() {
    _threadController.dispose();
    for (var controller in _referenceControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addReferenceField() {
    setState(() {
      _referenceControllers.add(TextEditingController());
    });
  }

  void _removeReferenceField(int index) {
    setState(() {
      _referenceControllers[index].dispose();
      _referenceControllers.removeAt(index);
    });
  }

  String _generatedThread = '';

  Future<void> _generateThread() async {
    try {
      _referenceControllers.first.text =
          'https://x.com/buildonnillion/status/1937541291325464969?s=46';
      if (!(_formKey.currentState?.validate() ?? false)) return;
      uploadLoading(status: true);

      String threadContent = _threadController.text;
      List<String> references = _referenceControllers
          .map((controller) => controller.text)
          .where((text) => text.isNotEmpty)
          .toList();

      // Build the full prompt
      String fullPrompt =
          "${PromptConstants.twitterThreadPrompt}\n\nREFERENCE LINKS:\n${references.asMap().entries.map((entry) => "${entry.key + 1}. ${entry.value}").join("\n")}";

      var response = await NillionApiService.sendMessage(
        "Generate thread based on ${references.length} references:\n\n$fullPrompt",
      );
      // For demo - in real app, you'd call your AI service here
      setState(() {
        _generatedThread = response.first.message.content;
      });

      // Show generated content in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Generated Thread'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thread Content:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                Text(
                  threadContent.isEmpty ? 'No thread content' : threadContent,
                ),

                SizedBox(height: 16),

                Text(
                  'References:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...references.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key + 1}. ${entry.value}'),
                  ),
                ),
                if (references.isEmpty) Text('No references added'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      uploadLoading(status: false);
    }
  }

  final _formKey = GlobalKey<FormState>();

  void _clearAll() {
    setState(() {
      _threadController.clear();
      for (var controller in _referenceControllers) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppImages.nillionIcon, width: 50),
            Text(
              'illion Thread Bot',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: _scrollController,

            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thread Content Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.grid_goldenratio_sharp,
                                color: Colors.blue[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Content',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          TextFormField(
                            controller: _threadController,
                            maxLines: 8,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter thread content'
                                : null,
                            decoration: InputDecoration(
                              hintText:
                                  'Write your Twitter thread content here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue[600]!,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // References Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.link, color: Colors.blue[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'References',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _addReferenceField,
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Add Reference',
                                  ),
                                  if (_referenceControllers.length > 1)
                                    IconButton(
                                      onPressed: () => _removeReferenceField(
                                        _referenceControllers.length - 1,
                                      ),
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Remove Last Reference',
                                    ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _referenceControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _referenceControllers[index],

                                        // validator: (value) => value!.isEmpty
                                        //     ? 'Reference field ${index + 1} is required}'
                                        //     : null,
                                        decoration: InputDecoration(
                                          labelText: 'Reference ${index + 1}',
                                          hintText: 'Enter URL or reference...',
                                          prefixIcon: Icon(
                                            Icons.link,
                                            size: 20,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.blue[600]!,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_referenceControllers.length > 1)
                                      IconButton(
                                        onPressed: () =>
                                            _removeReferenceField(index),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[400],
                                        ),
                                        tooltip: 'Remove this reference',
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clearAll,
                          icon: Icon(Icons.clear_all),
                          label: Text('Clear All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _generateThread,
                          icon: Icon(Icons.abc_outlined),
                          label: Text('Generate Thread'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
