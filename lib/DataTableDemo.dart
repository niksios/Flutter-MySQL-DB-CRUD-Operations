import 'package:flutter/material.dart';
import './Employee.dart';
import './Services.dart';

//Alt+Shift+F shortcut to format the code in neat structure.
class DataTableDemo extends StatefulWidget {
  DataTableDemo() : super();
  final String title = 'Employee Data';

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
  List<Employee> _employee;
  GlobalKey<ScaffoldState> _scaffolKey;

  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  Employee _selectedEmployee;
  bool _isUpdating;
  String _titleProgress;

  @override
  void initState() {
    super.initState();
    _employee = [];
    _isUpdating = false;
    _titleProgress = widget.title;
    _scaffolKey = GlobalKey(); // key to get the context to show a Snackbar

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _getEmployees();
  }

  //Method to update title in AppBar Title
  _showProgress(String message) {
    setState(() {
      _titleProgress = message;
    });
  }

  _showSnackBar(context, message) {
    _scaffolKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _createTable() {
    _showProgress('Creating Table..');
    Services.createTable().then((result) {
      if ('success' == result) {
        _showSnackBar(context, result);
        _showProgress(widget.title);
      }
    });
  }

//Add employee
  _addEmployee() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      print('Empty Fields');
      return;
    }
    _showProgress('Adding Employee..');
    Services.addEmployee(_firstNameController.text, _lastNameController.text)
        .then((result) {
      if ('success' == result) {
        _getEmployees(); //Refresh the list after addition of each employee
        _showSnackBar(context, result);
        _showProgress(widget.title);
        _clearValues();
      }
    });
  }

  _getEmployees() {
    _showProgress('Loading Employees..');
    Services.getEmployees().then((employees) {
      setState(() {
        _employee = employees;
      });
      _showProgress(widget.title); //Reset the title
      print("Length ${employees.length}");
    });
  }

  _updateEmployee(Employee employee) {
    setState(() {
      _isUpdating = true;
    });
    _showProgress('Updating Employee..');
    Services.updateEmployee(
            employee.id, _firstNameController.text, _lastNameController.text)
        .then((result) {
      if ('success' == result) {
        _getEmployees(); //Refresh the list after update
        setState(() {
          _isUpdating = false;
        });
        _showSnackBar(context, result);
        _showProgress(widget.title);
        _clearValues();
      }
    });
  }

  _deleteEmployee(Employee employee) {
    _showProgress('Deleting Employee..');
    Services.deleteEmployee(employee.id).then((result) {
      if ('success' == result) {
        _getEmployees(); //Refresh the list after delete
        _showSnackBar(context, result);
        _showProgress(widget.title);
        _clearValues();
      }
    });
  }

  //Method to clear Text Fields
  _clearValues() {
    _firstNameController.text = '';
    _lastNameController.text = '';
  }

  _showValues(Employee employee){
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
  }

  //Lets create a DataTable and show the employee list in it.
  SingleChildScrollView _dataBody() {
    //Both vertical and horizontal scroll view for DataTable
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('ID'),
            ),
            //Add other columns firstname and lastname
             DataColumn(
              label: Text('FIRST NAME'),
            ),
             DataColumn(
              label: Text('LAST NAME'),
            ),
             DataColumn(
              label: Text('DELETE'),
            ),
          ],
          rows: _employee.map((employee) =>
              DataRow(cells: [
                DataCell(
                  Text(employee.id),
                  //Add tap in the row and populate the 
                  //textfields with the corresponding values to update
                  onTap: (){
                    _showValues(employee);
                    // Set the selected employee to update
                    _selectedEmployee = employee;
                    //Set flag updating to true to indicate in Update Mode
                    setState(() {
                      _isUpdating = true;
                    });

                  },
                  ),
                  DataCell(
                  Text(employee.firstName.toUpperCase()
                   
                  ),
                  onTap: (){
                    _showValues(employee);
                    // Set the selected employee to update
                    _selectedEmployee = employee;
                    //Set flag updating to true to indicate in Update Mode
                    setState(() {
                      _isUpdating = true;
                    });

                  },
                  ),
                  DataCell(
                  Text(employee.lastName.toUpperCase()),
                  onTap: (){
                    _showValues(employee);
                    // Set the selected employee to update
                    _selectedEmployee = employee; 
                    //Set flag updating to true to indicate in Update Mode
                    setState(() {
                      _isUpdating = true;
                    });

                  },

                  ),

                  DataCell(IconButton(icon: Icon(Icons.delete),
                  onPressed: (){
                    _deleteEmployee(employee);
                  },))
                  
                  ]),
        ).toList(),
      ),
    ),
    );
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolKey,
      appBar: AppBar(
        title: Text(_titleProgress), //we show progress in title...
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _createTable();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getEmployees();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration.collapsed(hintText: 'First Name'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration.collapsed(hintText: 'Last Name'),
              ),
            ),
            //Add an update and cancel button
            //Show these button only when updating an employee
            _isUpdating
                ? Row(
                    children: <Widget>[
                      OutlineButton(
                        child: Text('UPDATE'),
                        onPressed: () {
                          _updateEmployee(_selectedEmployee);
                        },
                      ),
                      OutlineButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          setState(() {
                            _isUpdating = false;
                          });
                          _clearValues();
                        },
                      )
                    ],
                  )
                : Container(),
                Expanded(
                  child: _dataBody()

                ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEmployee();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
