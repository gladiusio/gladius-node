Setup
=================

Router setup
^^^^^^^^^^^^

**Ports that need to be forwarded**

.. list-table::
   :header-rows: 1

   * - Port
     - Service
   * - 8080
     - Networkd - Content server
   * - 7946
     - Controld - P2P Network

If you want to be able to visit sites that you host yourself, you'll need to
enable NAT Reflection/NAT Loopback/NAT Hairpinning on your router.

Using Node Manager UI
^^^^^^^^^^^^^^^^^^^^^

Use the Gladius Node Manager UI to go through onboarding and apply to a pool. No ether needed!

.. image:: https://image.ibb.co/gokiUe/Screen_Shot_2018_08_03_at_1_56_08_PM.png
   :target: https://image.ibb.co/gokiUe/Screen_Shot_2018_08_03_at_1_56_08_PM.png
   :alt:


Once you applied to a pool wait for the Pool Manager to accept your application. Once you've been accepted you're done! Your computer will automatically download and serve files.

You can monitor blockchain transactions on your account in the ``Transactions`` page.


.. image:: https://image.ibb.co/kNjXNz/Screen_Shot_2018_08_03_at_1_57_50_PM.png
   :target: https://image.ibb.co/kNjXNz/Screen_Shot_2018_08_03_at_1_57_50_PM.png
   :alt:


Using CLI
^^^^^^^^^

Notes
~~~~~~~~~~~~

.. note:: *Windows and macOS users:* If you installed through the ``.exe`` or ``.dmg`` in the releases section, ``gladius-networkd`` and ``gladius-controld`` are automatically added as system services. You should **NOT** attempt to run ``gladius-networkd`` and ``gladius-controld`` as commands because they are **already running**.

.. note:: *Linux users:* You need to run both the Gladius Control and Gladius Network daemons **and then** you can interact with them through the Gladius CLI. Scroll down to learn how to add the modules as services.

CLI Commands
~~~~~~~~~~~~

Full list of CLI commands can be found `here <https://github.com/gladiusio/gladius-cli/blob/master/README.md>`_
