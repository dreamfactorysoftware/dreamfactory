<?php
namespace DreamFactory\Http\Controllers;

class LaunchpadController extends Controller
{
    /**
     * Create new launchpad controller.
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * View for launchpad.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        return view('launchpad');
    }
}