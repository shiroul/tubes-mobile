import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationTestScreen extends StatefulWidget {
  const RegistrationTestScreen({super.key});

  @override
  State<RegistrationTestScreen> createState() => _RegistrationTestScreenState();
}

class _RegistrationTestScreenState extends State<RegistrationTestScreen> {
  String testResults = 'No tests run yet';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Tests'),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Registration Logic',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : testDirectFirestoreOperations,
              child: const Text('Test Direct Firestore Operations'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : testTimestampInArray,
              child: const Text('Test Timestamp in Array'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> testDirectFirestoreOperations() async {
    setState(() {
      isLoading = true;
      testResults = 'Testing direct Firestore operations...\n';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          testResults += 'ERROR: No authenticated user\n';
          isLoading = false;
        });
        return;
      }

      // Test 1: Create a test document
      setState(() {
        testResults += 'Test 1: Creating test document...\n';
      });

      final testDoc = await FirebaseFirestore.instance.collection('test_collection').add({
        'testField': 'test value',
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });

      setState(() {
        testResults += 'SUCCESS: Test document created with ID: ${testDoc.id}\n';
      });

      // Test 2: Update with array containing timestamp
      setState(() {
        testResults += 'Test 2: Updating with array containing timestamp...\n';
      });

      await FirebaseFirestore.instance.collection('test_collection').doc(testDoc.id).update({
        'testArray': [
          {
            'userId': user.uid,
            'timestamp': Timestamp.now(),
            'status': 'active'
          }
        ]
      });

      setState(() {
        testResults += 'SUCCESS: Array with timestamp updated\n';
      });

      // Test 3: Read back the document
      setState(() {
        testResults += 'Test 3: Reading back the document...\n';
      });

      final readDoc = await FirebaseFirestore.instance.collection('test_collection').doc(testDoc.id).get();
      if (readDoc.exists) {
        setState(() {
          testResults += 'SUCCESS: Document read successfully\n';
          testResults += 'Data: ${readDoc.data()}\n';
        });
      }

      // Clean up: Delete the test document
      setState(() {
        testResults += 'Cleaning up: Deleting test document...\n';
      });

      await FirebaseFirestore.instance.collection('test_collection').doc(testDoc.id).delete();

      setState(() {
        testResults += 'SUCCESS: Test document deleted\n';
        testResults += 'All tests passed! ✅\n';
      });

    } catch (e) {
      setState(() {
        testResults += 'ERROR: $e\n';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> testTimestampInArray() async {
    setState(() {
      isLoading = true;
      testResults = 'Testing timestamp handling in arrays...\n';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          testResults += 'ERROR: No authenticated user\n';
          isLoading = false;
        });
        return;
      }

      // Test with Timestamp.now() (should work)
      setState(() {
        testResults += 'Test 1: Using Timestamp.now() in array...\n';
      });

      final testDoc1 = await FirebaseFirestore.instance.collection('timestamp_test').add({
        'volunteers': [
          {
            'userId': user.uid,
            'registeredAt': Timestamp.now(), // This should work
            'status': 'confirmed'
          }
        ]
      });

      setState(() {
        testResults += 'SUCCESS: Timestamp.now() in array worked ✅\n';
      });

      // Clean up
      await FirebaseFirestore.instance.collection('timestamp_test').doc(testDoc1.id).delete();

      // Test with FieldValue.serverTimestamp() (should fail)
      setState(() {
        testResults += 'Test 2: Using FieldValue.serverTimestamp() in array (should fail)...\n';
      });

      try {
        final testDoc2 = await FirebaseFirestore.instance.collection('timestamp_test').add({
          'volunteers': [
            {
              'userId': user.uid,
              'registeredAt': FieldValue.serverTimestamp(), // This should fail
              'status': 'confirmed'
            }
          ]
        });
        
        setState(() {
          testResults += 'UNEXPECTED: FieldValue.serverTimestamp() in array succeeded (this should not happen)\n';
        });
        
        // Clean up if somehow it worked
        await FirebaseFirestore.instance.collection('timestamp_test').doc(testDoc2.id).delete();
        
      } catch (e) {
        setState(() {
          testResults += 'EXPECTED ERROR: FieldValue.serverTimestamp() in array failed: $e ❌\n';
          testResults += 'This confirms why we need to use Timestamp.now() instead\n';
        });
      }

      setState(() {
        testResults += '\nConclusion: Use Timestamp.now() for timestamps in arrays ✅\n';
      });

    } catch (e) {
      setState(() {
        testResults += 'ERROR: $e\n';
      });
    }

    setState(() {
      isLoading = false;
    });
  }
}
